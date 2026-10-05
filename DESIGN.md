# Design: terraform-oci-cluster

Why these modules look the way they do. Each decision names the evidence it
rests on; anything not yet checked against a real tenancy is listed under
"Unverified" and must be confirmed on the first reviewed apply.

Pins: `oracle/oci` 9.8.0. Runtimes: Terraform >= 1.5, OpenTofu >= 1.6.
Conventions: [CONVENTIONS.md](CONVENTIONS.md). Contract:
<https://captf.io/docs/module-author/contract/v1alpha1/>.

Provider facts below were read from the 9.8.0 sources
(`internal/service/<service>/*_resource.go`, `internal/provider/provider.go`,
`internal/tfresource/retry.go`) and `providers schema -json` of the pinned
provider; "ForceNew" means the attribute forces a replacement there.

The decision and "Unverified" numbers are the same in every terraform-oci-*
repository (they follow the cloud's original DESIGN.md), so a citation such as
"decision 6" means the same thing everywhere. A section that only concerns
another role is a one-line pointer under its original number.

## Scope

- One role, `cluster`: the cluster-wide resources of a `TerraformCluster`.. The other roles are in
  [terraform-oci-machine](https://github.com/captf-io/terraform-oci-machine/blob/main/DESIGN.md) and
  [terraform-oci-machinepool](https://github.com/captf-io/terraform-oci-machinepool/blob/main/DESIGN.md).
- Bring-your-own network: the VCN, subnets, gateways and route tables exist
  before the cluster. The cluster role creates network security groups, the
  API Network Load Balancer, and the node dynamic group and policy. Subnets
  need no DNS label: no resource sets a hostname label.
- The API load balancer is private by default; public is opt-in with an
  explicit allowed-CIDR list.
- Node identity (instance principals) is created by default; it can be
  turned off when an operator manages the dynamic group and policy.

## Decisions

### 1. API Network Load Balancer


- `oci_network_load_balancer_network_load_balancer`, `is_private = true` by
  default, with its own NSG.
- Backend sets with `is_preserve_source = false`: the backend sees the NLB
  as the source, so a control-plane node can reach itself through the VIP
  (hairpin). CAPOCI uses the same setting for its API NLB
  (`network_load_balancer_reconciler.go`).
- `policy = "FIVE_TUPLE"`, TCP health checks on the backend port; interval,
  timeout and retries stay OCI's (optional and computed, so no drift).
- One backend set and one listener per API listener key, `kube_apiserver`
  and, with `distribution = "rke2"`, `rke2_supervisor` (named with hyphens).
  The endpoint port is `cluster_network.api_server_port`, default 6443; the
  kube-apiserver backend port equals it with kubeadm and is always 6443
  with RKE2, whose supervisor listens on 9345 (control-planes/rke2.md;
  CONVENTIONS.md section 12). An NLB listener and its backends may use
  different ports. `api_server_port = 9345` with RKE2 fails a
  precondition.
- `terraform_data.api_endpoint_guard` records `api_load_balancer_public`,
  the load balancer subnet, `api_load_balancer_private_ip`,
  `api_load_balancer_reserved_public_ip_id`, `api_server_port` and the
  observed address when the load balancer is created (`ignore_changes =
  [input]`), and a postcondition per input fails any later plan that
  changes one: a port change would otherwise update the listener in place,
  and the destructive-plan guard catches replacements only. The address is
  recorded, not checked: a replaced load balancer's address is unknown at
  plan time, and the inputs that cause a replacement are checked already.
- ForceNew at 9.8.0: `is_private`, `subnet_id`, `assigned_private_ipv4`,
  `assigned_ipv6`; `reserved_ips` through a CustomizeDiff when an IPv4
  reservation changes. They are documented as immutable; the
  destructive-plan guard catches a change. Operators who need an endpoint
  that survives replacement set `api_load_balancer_private_ip` or
  `api_load_balancer_reserved_public_ip_id`. `network_security_group_ids`
  updates in place. `prevent_destroy` is not used: it would also block the
  cluster's own destroy.
- The endpoint host is the IPv4 entry of `ip_addresses` whose `is_public`
  matches `api_load_balancer_public`.
- A public NLB reached from nodes in private subnets goes through the NAT
  gateway, so the NAT gateway's public IP must be in the allowed CIDRs.
- With a user-supplied `control_plane_endpoint` there is no load balancer,
  `exports.api` is null, and the control-plane NSG opens the API port to
  the VCN and `api_allowed_cidrs` directly.
- Control-plane machines add themselves as backends of this load balancer in
  their own state; see [terraform-oci-machine DESIGN.md, decision 5](https://github.com/captf-io/terraform-oci-machine/blob/main/DESIGN.md#5-machine).

### 2. Network security groups


Three NSGs (control plane, workers, load balancer) with rules as keyed maps
(`<direction>-<proto>-<port>-<peer>`), one `for_each` rule resource per NSG,
so adding a rule never replaces the others. Control plane: API port (and
9345) from the LB NSG; all protocols from the control-plane and worker
NSGs; ICMP type 3 code 4 (path MTU) from the VCN; SSH only from
`ssh_allowed_cidrs` (empty by default). Workers: all from control-plane and
worker NSGs; ICMP 3/4; NodePorts (TCP and UDP) only from
`nodeport_allowed_cidrs` (empty by default). Load balancer: the API ports
from the VCN's CIDRs and `api_allowed_cidrs`, and egress to the
control-plane NSG on the same ports. Egress all for nodes. Only
`network_security_group_id` is ForceNew on a rule.

### 3. Failure domains


Availability domains when more than one is usable; otherwise the three
fault domains of the single AD (CAPOCI does the same). An AD-specific
control-plane subnet makes its AD the only usable one. The AD name is the
part after `:` (`US-ASHBURN-AD-1`), which is also the CCM's zone label
(`mapAvailabilityDomainToFailureDomain`, `zones.go` in
oci-cloud-controller-manager v1.36.0). `failure_domain_mode` (`auto`,
`availability_domain`, `fault_domain`) overrides the choice; forced
fault-domain mode uses the first usable AD. Exported attributes are
`availability_domain`, plus `fault_domain` in fault-domain mode only (the
contract's attributes are `map(string)`; an absent fault domain lets OCI
pick).

### 4. Node identity


A dynamic group matching the cluster's **control-plane** instances and a
policy granting the OCI CCM and CSI controller, which run there, their
permissions (`read instance-family`,
`use virtual-network-family`, `manage load-balancers`,
`manage network-load-balancers`, `manage volume-family`). The first three
are the CCM's documented instance-principal policy
(`manifests/provider-config-instance-principals-example.yaml`, v1.36.0);
the NLB and volume grants follow from NLB Services and the CSI driver. No
`manage security-lists`: the CCM is to run with
`securityListManagementMode: None`.

- Statements name the group and compartments by OCID
  (`Allow dynamic-group id <ocid> to ... in compartment id <ocid>`), which
  the policy syntax allows
  (<https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policysyntax.htm>)
  and which needs no identity-domain qualifier.
- `use virtual-network-family` is granted in the cluster's compartment and,
  when it differs, the VCN's. A policy governs only its own compartment and
  those below it, so a VCN in another compartment requires
  `node_policy_compartment_id` (a common ancestor); a precondition says so.
- Why control-plane only: `read instance-family` lets a principal read any
  instance's metadata through the API, and a control-plane instance's user
  data is the kubeadm payload with the cluster's CA keys. The control-plane
  checklist ("CP bootstrap payload size and secrecy") requires keeping key
  material out of readable metadata; a group of all nodes would hand it to
  every pod on every worker. Workers get no OCI permissions, and need none
  for block volumes: the CSI node driver is built without an OCI client
  (`newNodeDriver` in `pkg/csi/driver/driver.go` of oci-cloud-controller-manager
  v1.36.0 takes none; only `newControllerDriver` does), and the CCM and CSI
  controller are scheduled on control-plane nodes.
- The tag namespace and key are the operator's (BYO). A per-cluster
  namespace created by the module was rejected: a namespace must be retired
  before it is deleted, deletion is asynchronous and may take up to 48 hours,
  and its name is reusable only once deleted
  (<https://docs.oracle.com/en-us/iaas/Content/Tagging/Tasks/managingtagsandtagnamespaces.htm>,
  "Deleting Tag Key Definitions and Namespaces"), so a cluster destroy would
  stall and a recreated cluster of the same name would collide.
- Residual risk, documented in the cluster README "Limitations": the keys
  stay in control-plane metadata (readable from that instance's metadata
  service), and the policy's targets are the whole compartment, so
  control-plane nodes of another cluster in the compartment can read this
  cluster's. Hence one compartment per cluster. Staging the payload in OCI
  Vault would close it and is not implemented.
- Dynamic groups match on compartment, instance id or defined tags
  (free-form tags are not supported in matching rules,
  <https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm>):
  - with `node_identity.defined_tag` set, the rule is
    `All {instance.compartment.id = '<c>', tag.<ns>.<key>.value = '<namespace>/<cluster>/control-plane'}`.
    Control-plane machines carry that value (`exports.control_plane_defined_tags`),
    workers `<namespace>/<cluster>` (`exports.node_defined_tags`), which
    the rule does not match. Both are exported whenever the tag is set,
    also with `enabled = false`, so an operator-managed group can match
    them;
  - without it, the rule would be the whole compartment, workers and other
    clusters included, so a precondition refuses it unless
    `node_identity.allow_compartment_wide = true`.
- A policy statement about the root compartment says `in tenancy`, not
  `in compartment id <tenancy OCID>` (policy syntax).
- The dynamic group lives in the tenancy. The tenancy OCID is
  `tenancy_id`, else the identity's `OCI_TENANCY_OCID` file under
  `/var/run/captf/credentials` (the API-key identity carries it anyway); a
  precondition asks for it when neither exists (instance principals).
- IAM writes go to the home region through an `oci.home` provider alias
  (<https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingregions.htm>,
  "The Home Region"). Its region is `home_region`, else the home entry of
  `oci_identity_region_subscriptions`. Dynamic group and policy names are
  tenancy-unique and built from the hashed name prefix (`name_max` 80, so
  the role suffixes fit OCI's 100-character IAM names).

### 5. Machine

Concerns the machine role: see [terraform-oci-machine DESIGN.md](https://github.com/captf-io/terraform-oci-machine/blob/main/DESIGN.md#5-machine).

### 6. Machine pool

Concerns the machinepool role: see [terraform-oci-machinepool DESIGN.md](https://github.com/captf-io/terraform-oci-machinepool/blob/main/DESIGN.md#6-machine-pool).

### 7. provider_id, addresses, health

Concerns the machine and machinepool roles, except the cluster's own health:

- Cluster health from the NLB lifecycle state: ACTIVE or UPDATING (every
  backend change updates the NLB) → running; CREATING → pending; FAILED →
  degraded; DELETING, DELETED → terminated; gone → terminated. A user
  endpoint has nothing to observe: running.

For `provider_id`, addresses and instance health see [terraform-oci-machine DESIGN.md](https://github.com/captf-io/terraform-oci-machine/blob/main/DESIGN.md#7-provider_id-addresses-health);
for pool health, [terraform-oci-machinepool DESIGN.md](https://github.com/captf-io/terraform-oci-machinepool/blob/main/DESIGN.md#7-provider_id-addresses-health).

### 8. Subnet checks and teardown

The VCN and subnets are listed in the network compartment
(`oci_core_subnets`, `oci_core_vcns`; `network_compartment_id`, default
`compartment_id`) and picked by OCID, rather than read one by one: a read
of a deleted subnet fails, a listing returns empty, and a destroy refreshes
its data sources too (CONVENTIONS.md section 9). Their checks (found,
AVAILABLE, one VCN, regional or in the control-plane subnet's AD, public
subnet for a public load balancer) are preconditions on the control-plane
NSG and the load balancer, which a destroy skips. With the network gone the
NSGs' `vcn_id` is a placeholder, because OpenTofu's destroy still evaluates
required arguments; any other plan stops at the preconditions first. The
unit test `network_gone_refresh_succeeds` refreshes and tears down with
empty listings.

### 9. Tags


Free-form tag keys cannot contain periods or spaces, are case-insensitive,
and a resource carries at most 10 free-form tags
(<https://docs.oracle.com/en-us/iaas/Content/Tagging/Concepts/taggingoverview.htm>,
"Limits on Tags": keys printable ASCII without periods or spaces, at most
100 characters; values at most 256). Mapping: `.` and space to `_`
(`captf.io/cluster` → `captf_io/cluster`); values unchanged. The six captf
tags leave four slots, so `additional_tags` takes at most four entries, and
a precondition on each role's primary resource checks the total. Provider
blocks set `ignore_defined_tags = ["Oracle-Tags.CreatedBy",
"Oracle-Tags.CreatedOn"]` plus the user's `ignore_defined_tags`, so tenancy
tag defaults cause no drift. Not taggable: NSG rules, backend sets,
listeners and backends.

### 10. Credentials


Every provider argument falls back to `TF_VAR_<attr>` and then
`OCI_<ATTR>` (`MultiEnvDefaultFunc` with `tfVarName`/`ociVarName` in
`provider.go` 9.8.0); CAPTF drops `TF_VAR_*`, so the identity uses the
`OCI_*` forms:

```yaml
OCI_TENANCY_OCID: ocid1.tenancy.oc1..<id>
OCI_USER_OCID: ocid1.user.oc1..<id>
OCI_FINGERPRINT: "<aa:bb:...>"
OCI_PRIVATE_KEY_PATH: /var/run/captf/credentials/oci_api_key.pem
oci_api_key.pem: <PEM>
```

`OCI_PRIVATE_KEY` would take precedence over the path, so it is not used.
Config-file profiles read `$HOME/.oci/config`, and the runner sets `HOME`
to `/captf/work`, so profiles (and SecurityToken auth) are unusable. A
management cluster running on OCI can use `OCI_AUTH=InstancePrincipal`.
Modules set the region explicitly: `region` on the cluster, the exports'
region on machines and pools.

## Exports (`captf.io/oci-cluster/v1`)

```hcl
{
  schema                  = "captf.io/oci-cluster/v1"
  region                  = "<region>"
  compartment_id          = "<ocid>"
  vcn_id                  = "<ocid>"
  control_plane_subnet_id = "<ocid>"
  worker_subnet_id        = "<ocid>"
  control_plane_nsg_id    = "<ocid>"
  worker_nsg_id           = "<ocid>"
  failure_domains         = { "<name>" = { availability_domain = "...", fault_domain = "..." } } # fault_domain only in fault-domain mode
  node_defined_tags          = { "<ns>.<key>" = "<namespace>/<cluster>" }               # workers; {} without a defined tag
  control_plane_defined_tags = { "<ns>.<key>" = "<namespace>/<cluster>/control-plane" } # control-plane machines
  api = { # null for a user endpoint
    host                     = "<address>"
    port                     = 6443
    network_load_balancer_id = "<ocid>"
    kube_apiserver           = { backend_set_name = "kube-apiserver", port = 6443 }
    rke2_supervisor          = { backend_set_name = "rke2-supervisor", port = 9345 } # rke2 only
  }
}
```

Per listener, `api` names the backend set and the backend port (CONVENTIONS.md
section 12), so a control-plane machine registers in each with one
`for_each`.

## Unverified

**1.** Whether OCI accepts empty free-form tag values (`captf.io/template`).

**2.** IAM writes outside the home region through the alias; dynamic groups in
non-Default identity domains; a defined tag value with `/` in a
matching rule.

**3.** The minimal policy statements for NLB-backed Services and CSI, and the
minimal permissions of the identity listed in the role READMEs
(`inspect compartments` for availability domains, `inspect tenancies`
for region subscriptions, `use network-load-balancers` for backends).

**4.** Concerns the machinepool role: see [terraform-oci-machinepool DESIGN.md](https://github.com/captf-io/terraform-oci-machinepool/blob/main/DESIGN.md#unverified).

**5.** Concerns the machinepool role: see [terraform-oci-machinepool DESIGN.md](https://github.com/captf-io/terraform-oci-machinepool/blob/main/DESIGN.md#unverified).

**6.** Concerns the machinepool role: see [terraform-oci-machinepool DESIGN.md](https://github.com/captf-io/terraform-oci-machinepool/blob/main/DESIGN.md#unverified).

**7.** Idempotency of `shape_config`, `source_details`, defined tags and the
autoscaling rules' read-back (first real apply must show an empty second
plan).

**8.** Concerns the machine role: see [terraform-oci-machine DESIGN.md](https://github.com/captf-io/terraform-oci-machine/blob/main/DESIGN.md#unverified).

**9.** Concerns the machine role: see [terraform-oci-machine DESIGN.md](https://github.com/captf-io/terraform-oci-machine/blob/main/DESIGN.md#unverified).

**10.** Whether the CCM and CSI controller need any grant beyond the policy's
five statements when they run on control-plane nodes only.

## Rejected alternatives

- A compartment-wide dynamic group as the only option (grants every
  instance in the compartment).
- Config-file profiles (no `$HOME/.oci` in the Job).
- `prevent_destroy` on the API load balancer (blocks the cluster's own
  destroy).
- A node dynamic group of all nodes (workers would read control-plane user
  data with the CA keys).
