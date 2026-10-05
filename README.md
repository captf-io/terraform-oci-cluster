# terraform-oci-cluster

The CAPTF Oracle Cloud (OCI) cluster module: the Terraform/OpenTofu root module
behind `TerraformCluster`. It is run by the CAPTF runner inside a module image, with
`captf_*` inputs injected; it is not a general-purpose child module. Images
are published from [oci-modules](https://github.com/captf-io/oci-modules) as `ghcr.io/captf-io/oci-cluster`.

The `cluster` role for Oracle Cloud Infrastructure: the cluster-wide pieces a
`TerraformCluster` owns on a network you bring. It creates the network
security groups of the nodes, the API endpoint (a network load balancer) and
the nodes' instance-principal identity, and hands everything machines and
pools need to them through `exports`.

Image: `ghcr.io/captf-io/oci-cluster`. Contract:
[cluster role](https://captf.io/docs/module-author/contract/v1alpha1/cluster.html).
Design decisions: [DESIGN.md](https://github.com/captf-io/terraform-oci-cluster/blob/main/DESIGN.md).

## Usage

CAPTF runs this module from the module image `ghcr.io/captf-io/oci-cluster`: set the image on
a `TerraformCluster`'s `spec.source.image`, and the controller renders every
input. The module is also published to the Terraform Registry as
`captf-io/cluster/oci` and can be called directly:

```hcl
module "cluster" {
  source  = "captf-io/cluster/oci"
  version = "~> 0.1"

  # The contract inputs the controller would render (captf_contract,
  # captf_cluster, captf_object, captf_tags, ...; see Inputs), and any
  # user variables.
}
```

Called directly, the module is a CAPTF root module first:

- it configures its own `provider "oci"` block, so the calling
  module cannot use `count`, `for_each` or `depends_on` on it, and the
  provider takes its credentials from the environment (see Identity
  Secret);
- its providers are pinned to exact versions (`versions.tf`), which the
  calling configuration has to accept;
- you set the `captf_*` inputs yourself.

## What it creates

| Resource | Address | When |
| --- | --- | --- |
| Network security group, control-plane nodes | `oci_core_network_security_group.control_plane_nsg` | always |
| Network security group, worker nodes | `oci_core_network_security_group.worker_nsg` | always |
| Rules of both node NSGs | `oci_core_network_security_group_security_rule.control_plane_nsg_rules`, `.worker_nsg_rules` | always |
| Network load balancer for the API | `oci_network_load_balancer_network_load_balancer.api_load_balancer` | no `control_plane_endpoint` input |
| Its network security group and rules | `oci_core_network_security_group.api_load_balancer_nsg`, `oci_core_network_security_group_security_rule.api_load_balancer_nsg_rules` | same |
| Backend sets and listeners: `kube_apiserver` (named `kube-apiserver`), and `rke2_supervisor` on 9345 with `distribution = "rke2"` | `oci_network_load_balancer_backend_set.api_backend_sets`, `oci_network_load_balancer_listener.api_listeners` | same |
| Endpoint guard: records the inputs that decide the endpoint and fails any plan that changes them | `terraform_data.api_endpoint_guard` | same |
| Dynamic group of the control-plane nodes, in the tenancy | `oci_identity_dynamic_group.node_dynamic_group` | `node_identity.enabled` (default) |
| Policy for the cloud controller manager and CSI controller | `oci_identity_policy.node_policy` | same |

It lists the subnets and VCNs of the network compartment
(`data.oci_core_subnets.network_subnets`, `data.oci_core_vcns.network_vcns`)
and picks the cluster's by OCID, reads the region's availability domains,
the fault domains in single-AD regions, and the tenancy's region
subscriptions (to find the home region for IAM writes). Every subnet must be
found, AVAILABLE, in one VCN, and regional or in the control-plane subnet's
availability domain; these are preconditions, so a destroy after the
network is gone still finishes.

Network security group rules, keyed `<direction>-<protocol>-<port>-<peer>`:

| NSG | Allows in | Allows out |
| --- | --- | --- |
| control plane | everything from both node NSGs; the API backend ports (`api_server_port`, default 6443; 6443 and 9345 with RKE2) from the load balancer NSG, or from the VCN and `api_allowed_cidrs` with a user endpoint; ICMP 3/4 (path MTU) from the VCN; SSH from `ssh_allowed_cidrs` | everything |
| workers | everything from both node NSGs; ICMP 3/4 from the VCN; NodePorts 30000-32767 (TCP and UDP) from `nodeport_allowed_cidrs`; SSH from `ssh_allowed_cidrs` | everything |
| API load balancer | the API ports from the VCN's CIDRs and `api_allowed_cidrs` | the API ports to the control-plane NSG |

## Prerequisites

- **Network.** An existing VCN with a regional subnet for control-plane
  nodes (and optionally one for workers and one for the load balancer), a
  route to the internet for the nodes (a NAT gateway for private subnets),
  and a service gateway or NAT route to the OCI APIs. The module creates no
  network. Security lists stay yours; the module's rules live in NSGs.
- **A public endpoint** (`api_load_balancer_public = true`) needs a public
  subnet for the load balancer and `api_allowed_cidrs`. Nodes in private
  subnets reach a public endpoint through the NAT gateway, so its public IP
  belongs in `api_allowed_cidrs`.
- **A defined-tag namespace and key** for `node_identity.defined_tag`
  (create them once per tenancy). Control-plane machines get the value
  `<namespace>/<cluster>/control-plane`, which the dynamic group matches;
  workers get `<namespace>/<cluster>`, which it does not. Without a defined
  tag the module fails the plan unless `node_identity.allow_compartment_wide`
  accepts a group of every instance in the compartment, or
  `node_identity.enabled = false`.
- **One compartment per cluster** is still recommended (below).
- **Quotas:** one network load balancer, three NSGs, one dynamic group and
  one policy per cluster.
- **Permissions** of the identity's user (or instance principal):

  ```text
  Allow group <group> to use virtual-network-family in compartment <network compartment>
  Allow group <group> to manage network-security-groups in compartment <compartment>
  Allow group <group> to manage network-load-balancers in compartment <compartment>
  Allow group <group> to inspect compartments in tenancy
  # Node identity (node_identity.enabled, the default):
  Allow group <group> to manage dynamic-groups in tenancy
  Allow group <group> to manage policies in compartment <node policy compartment>
  Allow group <group> to inspect tenancies in tenancy
  # node_identity.defined_tag:
  Allow group <group> to use tag-namespaces in tenancy
  ```

## Inputs

Contract inputs used: `captf_cluster` (names), `captf_tags` (tags),
`control_plane_endpoint` (skips the load balancer), `cluster_network`
(`api_server_port`). `captf_contract` is validated; `captf_object`,
`kubernetes_version`, `control_plane_initialized` and
`captf_cluster_outputs` are declared and unused.

User variables (`spec.variables` on the `TerraformCluster`):

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `compartment_id` | `string` | required | Compartment of every cluster resource, machines and pools included. |
| `region` | `string` | required | Region identifier, such as `us-ashburn-1`. Machines and pools inherit it. |
| `control_plane_subnet_id` | `string` | required | Subnet of the control-plane nodes; its VCN is the cluster's. |
| `worker_subnet_id` | `string` | control-plane subnet | Subnet of the workers, in the same VCN. |
| `api_load_balancer_subnet_id` | `string` | control-plane subnet | Subnet of the API load balancer. |
| `api_load_balancer_public` | `bool` | `false` | Give the load balancer a public IP; requires `api_allowed_cidrs`. |
| `api_allowed_cidrs` | `list(string)` | `[]` | CIDRs that may reach the API, besides the VCN's. |
| `api_load_balancer_private_ip` | `string` | `null` | Pin the load balancer's private IP. |
| `api_load_balancer_reserved_public_ip_id` | `string` | `null` | Reserved public IP of a public load balancer. |
| `distribution` | `string` | `kubeadm` | `kubeadm` or `rke2`: RKE2 adds the supervisor listener on 9345 and puts the kube-apiserver backends on 6443, whatever `api_server_port` is. |
| `ssh_allowed_cidrs` | `list(string)` | `[]` | CIDRs that may reach the nodes on SSH. |
| `nodeport_allowed_cidrs` | `list(string)` | `[]` | CIDRs that may reach worker NodePorts. |
| `failure_domain_mode` | `string` | `auto` | `availability_domain`, `fault_domain` or `auto` (below). |
| `network_compartment_id` | `string` | `compartment_id` | Compartment of the VCN and its subnets. |
| `node_identity` | `object({enabled = optional(bool, true), defined_tag = optional(object({namespace = string, key = string})), allow_compartment_wide = optional(bool, false)})` | `{}` | Create the control-plane dynamic group and policy; `defined_tag` scopes the group to this cluster's control-plane instances and is required unless `enabled = false` or `allow_compartment_wide = true`. |
| `node_policy_compartment_id` | `string` | `compartment_id` | Where the node policy is attached; an ancestor when the VCN is in another compartment. |
| `tenancy_id` | `string` | the identity's `OCI_TENANCY_OCID` file | Tenancy of the dynamic group. |
| `home_region` | `string` | looked up | The tenancy's home region, for IAM writes. |
| `ignore_defined_tags` | `list(string)` | `[]` | Tag-default keys (`<namespace>.<key>`) to ignore, besides `Oracle-Tags.CreatedBy` and `CreatedOn`. |
| `additional_tags` | `map(string)` | `{}` | Extra free-form tags; at most 4. |

## Outputs

| Name | Value |
| --- | --- |
| `control_plane_endpoint` | The input when given; else the load balancer's IPv4 address (public when `api_load_balancer_public`, else private) and the API port. |
| `failure_domains` | One entry per availability domain, or per fault domain of the one availability domain (below); all `control_plane = true`. |
| `exports` | Below. |
| `health` | From the load balancer's lifecycle state (below). |
| `api_load_balancer_id` | OCID of the network load balancer (not a contract output). |
| `node_dynamic_group_id` | OCID of the node dynamic group, for your own policies (not a contract output). |
| `node_policy_id` | OCID of the node policy (not a contract output). |

**Failure domains.** `auto` picks availability domains where the region (or
an AD-specific control-plane subnet) offers more than one, else the three
fault domains of the single availability domain, as CAPOCI does. An
availability domain is named as the OCI cloud controller manager names the
zone: the part after the tenancy prefix (`Uocm:US-ASHBURN-AD-1` becomes
`US-ASHBURN-AD-1`). Fault domains keep OCI's names (`FAULT-DOMAIN-1`).

## Exports

Schema `captf.io/oci-cluster/v1`, injected into machines and pools as
`captf_cluster_outputs`. Adding a key keeps the schema; renaming or removing
one bumps it to `v2`.

```hcl
{
  schema                  = "captf.io/oci-cluster/v1"
  region                  = "us-ashburn-1"
  compartment_id          = "ocid1.compartment.oc1..<id>"
  vcn_id                  = "ocid1.vcn.oc1.iad.<id>"
  control_plane_subnet_id = "ocid1.subnet.oc1.iad.<id>"
  worker_subnet_id        = "ocid1.subnet.oc1.iad.<id>"
  control_plane_nsg_id    = "ocid1.networksecuritygroup.oc1.iad.<id>"
  worker_nsg_id           = "ocid1.networksecuritygroup.oc1.iad.<id>"
  # Failure domain name -> placement; fault_domain only in fault-domain mode.
  failure_domains = {
    "US-ASHBURN-AD-1" = { availability_domain = "Uocm:US-ASHBURN-AD-1" }
  }
  # Defined tags for workers and for control-plane machines (the value the
  # dynamic group matches); {} without node_identity.defined_tag.
  node_defined_tags          = { "<tag namespace>.<key>" = "<namespace>/<cluster>" }
  control_plane_defined_tags = { "<tag namespace>.<key>" = "<namespace>/<cluster>/control-plane" }
  # The endpoint and where control-plane machines register, per listener;
  # null with a user endpoint.
  api = {
    host                     = "10.0.0.10"
    port                     = 6443
    network_load_balancer_id = "ocid1.networkloadbalancer.oc1.iad.<id>"
    kube_apiserver           = { backend_set_name = "kube-apiserver", port = 6443 }
    rke2_supervisor          = { backend_set_name = "rke2-supervisor", port = 9345 } # rke2 only
  }
}
```

An externally managed `TerraformCluster` gives machines and pools `{}`; set
`external_cluster_exports` on them to an object of this shape instead.

## Identity Secret

See the [oci-modules README](https://github.com/captf-io/oci-modules#using-it) and
[`examples/identity.yaml`](https://github.com/captf-io/terraform-oci-cluster/blob/main/examples/identity.yaml): `OCI_TENANCY_OCID`,
`OCI_USER_OCID`, `OCI_FINGERPRINT`, `OCI_PRIVATE_KEY_PATH` and the PEM key as
a file key. The region comes from `region`, never from the identity.

## Tags

Every taggable resource carries `captf_tags` as OCI free-form tags. Free-form
keys may not contain periods or spaces, so `.` and space become `_`:
`captf.io/cluster` is `captf_io/cluster`. Values are unchanged. OCI allows 10
free-form tags per resource and the six captf tags always apply, so
`additional_tags` takes at most four entries, none starting with `captf_io/`
(keys are case-insensitive).

Not taggable in OCI: NSG rules, backend sets and listeners.

The provider ignores the defined tags `Oracle-Tags.CreatedBy` and
`Oracle-Tags.CreatedOn` that tenancy tag defaults add; list your own tag
defaults in `ignore_defined_tags`.

## Health

From the API network load balancer's lifecycle state; never from its
backends, which are unhealthy during every normal control-plane bring-up.

| Load balancer state | `health.state` | `healthy` | `reasons` |
| --- | --- | --- | --- |
| `ACTIVE`, `UPDATING` (every backend change) | `running` | `true` | `[]` |
| `CREATING` | `pending` | `false` | `LoadBalancerCreating` |
| `FAILED` | `degraded` | `false` | `LoadBalancerFailed` |
| `DELETING`, `DELETED` | `terminated` | `false` | `LoadBalancerDeleting`, `LoadBalancerDeleted` |
| gone from state (the provider drops a `DELETED` load balancer on read) | `terminated` | `false` | `LoadBalancerNotFound` |
| anything else | `unknown` | `false` | `LoadBalancer<State>` |

With a user-supplied endpoint there is no load balancer to observe: the
cluster reports `running` and healthy.

## Endpoint guard

`terraform_data.api_endpoint_guard` records, when the load balancer is
created, `api_load_balancer_public`, the load balancer subnet,
`api_load_balancer_private_ip`, `api_load_balancer_reserved_public_ip_id`,
`cluster_network.api_server_port` and the address it got. Any later plan
that changes one of the inputs fails ("The API endpoint of this cluster is
fixed once its load balancer exists: …"): CAPI never updates an endpoint,
a port change would update the listener in place, and CAPTF's
destructive-plan guard only catches replacements. Revert the change, or
create a new cluster.

## Limitations

- **The endpoint is fixed.** The endpoint guard (above) refuses any change to
  the inputs behind it; switching to a user-supplied endpoint removes the
  load balancer and the guard with it, which the destructive-plan guard
  holds for approval.
- **The cloud controller manager is yours to install.** Configure it with
  `useInstancePrincipals: true`, the cluster's `compartment_id` and
  `vcn_id`, and `securityListManagementMode: None`, and schedule it and the
  CSI controller on control-plane nodes, the only ones the dynamic group
  matches: the node policy grants
  no `manage security-lists`. Open Service NodePorts to the load balancer
  subnets with `nodeport_allowed_cidrs`.
- **Instance metadata holds the cluster's CA keys.** A control-plane
  instance's user data is the kubeadm payload, CA and service-account keys
  included. It is readable from that instance's metadata service (any pod
  there that reaches 169.254.169.254) and, through the OCI API, by any
  principal that may read instances in the compartment. The node policy
  grants that only to control-plane instances, which hold the keys anyway,
  but those of other clusters in the same compartment can read this
  cluster's: keep one compartment per cluster, and block pod access to the
  metadata service on control-plane nodes. Staging the payload in OCI Vault
  is not implemented.
- **The node policy covers the compartment.** Control-plane nodes can manage
  every load balancer, network load balancer and volume there (and use the
  VCN's network), as the cloud controller manager and CSI controller need.
  Workers get nothing: OCI API calls from workers need your own policy.
- **A deleted node NSG** leaves the cluster's exports incomplete until the
  next apply recreates it; machines and pools re-rendered meanwhile fail
  their exports checks.
- **IAM propagation.** OCI applies new policies within minutes; the first
  nodes may retry their first OCI calls.
- **Identity domains.** The dynamic group is created through the classic IAM
  API, in the tenancy's Default domain.

## Exceptions

- `tfcapi-lint module --strict` passes without allowed warnings.
- Besides node-to-node traffic and the API port from the load balancer
  (CONVENTIONS.md section 8), two rules are open by default: ICMP type 3
  code 4 from the VCN, so path MTU discovery works, and, with a
  user-supplied endpoint, the API backend ports from the VCN and
  `api_allowed_cidrs` on the control-plane NSG, since that endpoint reaches
  the nodes directly.
- Once the operator's network is gone, the network security groups get a
  placeholder `vcn_id`: OpenTofu's destroy still evaluates required
  arguments, and the listings no longer find the VCN. Any other plan stops
  at the subnet preconditions first, so the placeholder never reaches the
  API (DESIGN.md decision 8).

## Examples

Variables on a `TerraformCluster`, as in
[`examples/cluster-kubeadm.yaml`](https://github.com/captf-io/terraform-oci-cluster/blob/main/examples/cluster-kubeadm.yaml):

```yaml
spec:
  variables:
    compartment_id: ocid1.compartment.oc1..<id>
    region: us-ashburn-1
    control_plane_subnet_id: ocid1.subnet.oc1.iad.<id>
    worker_subnet_id: ocid1.subnet.oc1.iad.<id>
    node_identity:
      defined_tag:
        namespace: captf
        key: cluster
```

## Development

The host needs `make`, `podman` (or `docker` with `ENGINE=docker`), `jq` and
Go; every other tool runs in a container pinned by digest. `make verify` is
the gate. Override variables on the command line, for example
`make validate RUNTIMES=opentofu`.

| Target | What it does |
| --- | --- |
| `make fmt` | Format the module with `terraform fmt` and `tofu fmt`, in place. |
| `make fmt-check` | Fail on any file either formatter would change. |
| `make validate` | `init` and `validate` on both runtimes and on their floors (Terraform 1.5.7, OpenTofu 1.6.3). |
| `make unit-test` | `terraform test` and `tofu test` with mocked providers. |
| `make tflint` | `tflint` with the Terraform ruleset (preset all) and the cloud ruleset. |
| `make tfcapi-lint` | `tfcapi-lint module --strict`; skips when the linter is unavailable. |
| `make scan` | `trivy config` over the repository (HCL, workflows). |
| `make check-conventions` | `hack/check-layout.sh` (CONVENTIONS.md sections 2 and 4) and `hack/check-tags.sh` (section 7). |
| `make shellcheck` | `shellcheck` over `hack/` and every shell template, rendered with placeholders. |
| `make check-headers` | Fail on any source file without the Apache-2.0 license header. |
| `make fix-headers` | Add the license header to every source file missing it. |
| `make verify` | All of the above, in parallel groups: static checks, then one group per runtime. |
| `make clean` | Remove `build/`; keeps `.cache/` and `.tools/`. |

`tfcapi-lint` is built from the provider repository, found through
`PROVIDER_DIR` (default `../cluster-api-provider-terraform`). The repository
holds the code only: the module images are built and published from
[oci-modules](https://github.com/captf-io/oci-modules).
