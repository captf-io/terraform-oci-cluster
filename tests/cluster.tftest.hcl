# Copyright 2026 The CAPTF Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Unit tests of the cluster role with mocked OCI providers: no tenancy is
# contacted. Run from the role directory: `terraform test` or `tofu test`
# (`make unit-test` runs both). Mock defaults are realistic: OCIDs, states,
# availability domain names and load balancer addresses as OCI returns them.

mock_provider "oci" {
  mock_data "oci_core_subnets" {
    defaults = {
      subnets = [
        { availability_domain = "", cidr_block = "10.0.0.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaacontrolplane", id = "ocid1.subnet.oc1.iad.aaaaaaaacontrolplane", prohibit_public_ip_on_vnic = true, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = true, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
        { availability_domain = "", cidr_block = "10.0.1.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaaworkers", id = "ocid1.subnet.oc1.iad.aaaaaaaaworkers", prohibit_public_ip_on_vnic = true, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = true, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
      ]
    }
  }
  mock_data "oci_core_vcns" {
    defaults = {
      virtual_networks = [
        { cidr_blocks = ["10.0.0.0/16"], compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "vcn", id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", state = "AVAILABLE", byoipv6cidr_blocks = [], byoipv6cidr_details = [], cidr_block = "10.0.0.0/16", default_dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", default_route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", default_security_list_id = "ocid1.securitylist.oc1.iad.aaaaaaaalist", defined_tags = {}, dns_label = "", freeform_tags = {}, ipv6cidr_blocks = [], ipv6private_cidr_blocks = [], is_ipv6enabled = false, is_oracle_gua_allocation_enabled = false, security_attributes = {}, time_created = "2026-01-01 00:00:00 +0000 UTC", vcn_domain_name = "" },
      ]
    }
  }
  mock_data "oci_identity_availability_domains" {
    defaults = {
      availability_domains = [
        { compartment_id = "ocid1.tenancy.oc1..aaaaaaaatenancy", id = "ocid1.availabilitydomain.oc1..ad1", name = "Uocm:US-ASHBURN-AD-1" },
        { compartment_id = "ocid1.tenancy.oc1..aaaaaaaatenancy", id = "ocid1.availabilitydomain.oc1..ad2", name = "Uocm:US-ASHBURN-AD-2" },
        { compartment_id = "ocid1.tenancy.oc1..aaaaaaaatenancy", id = "ocid1.availabilitydomain.oc1..ad3", name = "Uocm:US-ASHBURN-AD-3" },
      ]
    }
  }
  mock_data "oci_identity_fault_domains" {
    defaults = {
      fault_domains = [
        { availability_domain = "Uocm:US-ASHBURN-AD-1", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", id = "ocid1.faultdomain.oc1..fd1", name = "FAULT-DOMAIN-1" },
        { availability_domain = "Uocm:US-ASHBURN-AD-1", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", id = "ocid1.faultdomain.oc1..fd2", name = "FAULT-DOMAIN-2" },
        { availability_domain = "Uocm:US-ASHBURN-AD-1", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", id = "ocid1.faultdomain.oc1..fd3", name = "FAULT-DOMAIN-3" },
      ]
    }
  }
  mock_data "oci_identity_region_subscriptions" {
    defaults = {
      region_subscriptions = [
        { is_home_region = false, region_key = "IAD", region_name = "us-ashburn-1", state = "READY", tenancy_id = "ocid1.tenancy.oc1..aaaaaaaatenancy" },
        { is_home_region = true, region_key = "PHX", region_name = "us-phoenix-1", state = "READY", tenancy_id = "ocid1.tenancy.oc1..aaaaaaaatenancy" },
      ]
    }
  }
  mock_resource "oci_core_network_security_group" {
    defaults = {
      state = "AVAILABLE"
    }
  }
  mock_resource "oci_network_load_balancer_network_load_balancer" {
    defaults = {
      ip_addresses = [
        { ip_address = "10.0.0.10", ip_version = "IPV4", is_public = false, reserved_ip = [] },
      ]
      state = "ACTIVE"
    }
  }
}

mock_provider "oci" {
  alias = "home"

  mock_resource "oci_identity_dynamic_group" {
    defaults = {
      state = "ACTIVE"
    }
  }
  mock_resource "oci_identity_policy" {
    defaults = {
      state = "ACTIVE"
    }
  }
}

variables {
  captf_contract = "v1alpha1"
  captf_cluster  = { name = "demo", namespace = "team-a" }
  captf_object   = { kind = "TerraformCluster", name = "demo", namespace = "team-a" }
  captf_tags = {
    "captf.io/cluster"    = "demo"
    "captf.io/namespace"  = "team-a"
    "captf.io/kind"       = "TerraformCluster"
    "captf.io/name"       = "demo"
    "captf.io/managed-by" = "captf"
    "captf.io/template"   = ""
  }
  control_plane_endpoint    = null
  kubernetes_version        = "v1.34.1"
  control_plane_initialized = false
  cluster_network = {
    pods            = ["192.168.0.0/16"]
    services        = ["10.128.0.0/12"]
    service_domain  = "cluster.local"
    api_server_port = 6443
  }

  compartment_id          = "ocid1.compartment.oc1..aaaaaaaacluster"
  region                  = "us-ashburn-1"
  control_plane_subnet_id = "ocid1.subnet.oc1.iad.aaaaaaaacontrolplane"
  worker_subnet_id        = "ocid1.subnet.oc1.iad.aaaaaaaaworkers"
  tenancy_id              = "ocid1.tenancy.oc1..aaaaaaaatenancy"
  node_identity           = { defined_tag = { namespace = "captf", key = "cluster" } }
}

run "happy_path" {
  assert {
    condition     = output.control_plane_endpoint == { host = "10.0.0.10", port = 6443 }
    error_message = "control_plane_endpoint must be the private load balancer address on the API port."
  }
  assert {
    condition = output.failure_domains == [
      { name = "US-ASHBURN-AD-1", control_plane = true, attributes = { availability_domain = "Uocm:US-ASHBURN-AD-1" } },
      { name = "US-ASHBURN-AD-2", control_plane = true, attributes = { availability_domain = "Uocm:US-ASHBURN-AD-2" } },
      { name = "US-ASHBURN-AD-3", control_plane = true, attributes = { availability_domain = "Uocm:US-ASHBURN-AD-3" } },
    ]
    error_message = "A three-AD region must report its availability domains, named as the cloud controller manager names zones."
  }
  assert {
    condition     = output.exports.schema == "captf.io/oci-cluster/v1" && output.exports.region == "us-ashburn-1" && output.exports.compartment_id == "ocid1.compartment.oc1..aaaaaaaacluster"
    error_message = "exports must carry the schema, region and compartment."
  }
  assert {
    condition     = output.exports.vcn_id == "ocid1.vcn.oc1.iad.aaaaaaaavcn" && output.exports.control_plane_subnet_id == "ocid1.subnet.oc1.iad.aaaaaaaacontrolplane" && output.exports.worker_subnet_id == "ocid1.subnet.oc1.iad.aaaaaaaaworkers"
    error_message = "exports must carry the VCN and both node subnets."
  }
  assert {
    condition     = output.exports.control_plane_nsg_id == oci_core_network_security_group.control_plane_nsg[0].id && output.exports.worker_nsg_id == oci_core_network_security_group.worker_nsg[0].id
    error_message = "exports must carry both node NSGs."
  }
  assert {
    condition     = output.exports.api.host == "10.0.0.10" && output.exports.api.port == 6443 && output.exports.api.network_load_balancer_id == oci_network_load_balancer_network_load_balancer.api_load_balancer[0].id
    error_message = "exports.api must carry the endpoint and the load balancer."
  }
  assert {
    condition     = output.exports.api.kube_apiserver.backend_set_name == "kube-apiserver" && output.exports.api.kube_apiserver.port == 6443 && !contains(keys(output.exports.api), "rke2_supervisor")
    error_message = "exports.api must name the kube-apiserver backend set and its port, and no RKE2 supervisor with kubeadm."
  }
  assert {
    condition     = output.exports.node_defined_tags["captf.cluster"] == "team-a/demo" && output.exports.control_plane_defined_tags["captf.cluster"] == "team-a/demo/control-plane" && length(output.exports.node_defined_tags) == 1
    error_message = "Workers and control-plane machines must learn their distinct defined-tag values."
  }
  assert {
    condition     = output.health.state == "running" && output.health.healthy && output.health.message == "API network load balancer is ACTIVE" && length(output.health.reasons) == 0
    error_message = "An ACTIVE load balancer is a running, healthy cluster."
  }
  assert {
    condition     = output.api_load_balancer_id == oci_network_load_balancer_network_load_balancer.api_load_balancer[0].id && output.node_dynamic_group_id == oci_identity_dynamic_group.node_dynamic_group[0].id && output.node_policy_id == oci_identity_policy.node_policy[0].id
    error_message = "The extra outputs must name the load balancer, dynamic group and policy."
  }
  assert {
    condition     = oci_network_load_balancer_network_load_balancer.api_load_balancer[0].is_private && oci_network_load_balancer_network_load_balancer.api_load_balancer[0].subnet_id == "ocid1.subnet.oc1.iad.aaaaaaaacontrolplane"
    error_message = "The load balancer must be private and default to the control-plane subnet."
  }
  assert {
    condition     = oci_network_load_balancer_backend_set.api_backend_sets["kube_apiserver"].is_preserve_source == false && oci_network_load_balancer_backend_set.api_backend_sets["kube_apiserver"].health_checker[0].protocol == "TCP"
    error_message = "The backend set must not preserve the source (hairpin) and must health-check over TCP."
  }
  assert {
    condition     = oci_network_load_balancer_listener.api_listeners["kube_apiserver"].port == 6443 && oci_network_load_balancer_listener.api_listeners["kube_apiserver"].default_backend_set_name == "kube-apiserver"
    error_message = "The listener must serve 6443 from the kube-apiserver backend set."
  }
  assert {
    condition     = sort(keys(oci_network_load_balancer_listener.api_listeners)) == tolist(["kube_apiserver"])
    error_message = "With kubeadm there is one listener only."
  }
  assert {
    condition     = oci_identity_dynamic_group.node_dynamic_group[0].compartment_id == "ocid1.tenancy.oc1..aaaaaaaatenancy" && oci_identity_dynamic_group.node_dynamic_group[0].matching_rule == "All {instance.compartment.id = 'ocid1.compartment.oc1..aaaaaaaacluster', tag.captf.cluster.value = 'team-a/demo/control-plane'}"
    error_message = "The dynamic group lives in the tenancy and matches this cluster's control-plane instances only: workers must never read the control plane's user data."
  }
  assert {
    condition     = oci_identity_policy.node_policy[0].compartment_id == "ocid1.compartment.oc1..aaaaaaaacluster" && length(oci_identity_policy.node_policy[0].statements) == 5
    error_message = "The node policy lives in the cluster compartment with five statements."
  }
  assert {
    condition     = alltrue([for s in oci_identity_policy.node_policy[0].statements : startswith(s, "Allow dynamic-group id ${oci_identity_dynamic_group.node_dynamic_group[0].id} to ")])
    error_message = "Every policy statement must grant to the node dynamic group by OCID."
  }
  assert {
    condition     = local.home_region == "us-phoenix-1"
    error_message = "IAM writes must go to the home region from the region subscriptions."
  }
  assert {
    condition     = local.name_prefix == "captf-team-a-demo-${substr(sha256("team-a/demo"), 0, 8)}" && oci_identity_dynamic_group.node_dynamic_group[0].name == "${local.name_prefix}-control-plane"
    error_message = "Names derive from the cluster's namespace and name plus a hash."
  }
  assert {
    condition = sort(keys(oci_core_network_security_group_security_rule.control_plane_nsg_rules)) == sort([
      "egress-all-all-anywhere",
      "ingress-all-all-control-plane",
      "ingress-all-all-workers",
      "ingress-icmp-3.4-10.0.0.0/16",
      "ingress-tcp-6443-api-load-balancer",
    ])
    error_message = "The control-plane NSG must allow the API from the load balancer, all node traffic, path MTU and egress, and nothing else (no SSH by default)."
  }
  assert {
    condition = sort(keys(oci_core_network_security_group_security_rule.worker_nsg_rules)) == sort([
      "egress-all-all-anywhere",
      "ingress-all-all-control-plane",
      "ingress-all-all-workers",
      "ingress-icmp-3.4-10.0.0.0/16",
    ])
    error_message = "The worker NSG must allow node traffic, path MTU and egress, and nothing else (no NodePorts or SSH by default)."
  }
  assert {
    condition = sort(keys(oci_core_network_security_group_security_rule.api_load_balancer_nsg_rules)) == sort([
      "egress-tcp-6443-control-plane",
      "ingress-tcp-6443-10.0.0.0/16",
    ])
    error_message = "The load balancer NSG must admit the API from the VCN only and forward to the control plane."
  }
  assert {
    condition     = oci_core_network_security_group_security_rule.control_plane_nsg_rules["ingress-tcp-6443-api-load-balancer"].source == oci_core_network_security_group.api_load_balancer_nsg[0].id && oci_core_network_security_group_security_rule.control_plane_nsg_rules["ingress-tcp-6443-api-load-balancer"].tcp_options[0].destination_port_range[0].min == 6443
    error_message = "The API rule must admit TCP 6443 from the load balancer NSG."
  }
  assert {
    condition     = oci_core_network_security_group_security_rule.control_plane_nsg_rules["ingress-icmp-3.4-10.0.0.0/16"].icmp_options[0].type == 3 && oci_core_network_security_group_security_rule.control_plane_nsg_rules["ingress-icmp-3.4-10.0.0.0/16"].icmp_options[0].code == 4
    error_message = "The path MTU rule must be ICMP type 3 code 4."
  }
}

# Must follow happy_path directly: OpenTofu 1.12 reports an unknown condition
# for outputs of an earlier, non-adjacent run.
# Mocks never plan a replacement, so this proves only that nothing in the
# configuration itself churns; provider normalisation is DESIGN.md
# "Unverified" 7.
run "reapply_is_stable" {
  variables {
    previous_exports               = run.happy_path.exports
    previous_endpoint              = run.happy_path.control_plane_endpoint
    previous_load_balancer_id      = run.happy_path.api_load_balancer_id
    previous_node_dynamic_group_id = run.happy_path.node_dynamic_group_id
    previous_node_policy_id        = run.happy_path.node_policy_id
  }

  assert {
    condition = (
      oci_core_network_security_group.control_plane_nsg[0].id == var.previous_exports.control_plane_nsg_id &&
      oci_core_network_security_group.worker_nsg[0].id == var.previous_exports.worker_nsg_id &&
      oci_network_load_balancer_network_load_balancer.api_load_balancer[0].id == var.previous_load_balancer_id &&
      oci_identity_dynamic_group.node_dynamic_group[0].id == var.previous_node_dynamic_group_id &&
      oci_identity_policy.node_policy[0].id == var.previous_node_policy_id
    )
    error_message = "A second identical apply must keep every resource."
  }
  assert {
    condition     = output.control_plane_endpoint == var.previous_endpoint
    error_message = "A second identical apply must keep the endpoint."
  }
}

run "tags_on_taggable_resources" {
  variables {
    additional_tags = { CostCenter = "42" }
  }

  assert {
    condition = alltrue([for t in [
      oci_core_network_security_group.control_plane_nsg[0].freeform_tags,
      oci_core_network_security_group.worker_nsg[0].freeform_tags,
      oci_core_network_security_group.api_load_balancer_nsg[0].freeform_tags,
      oci_network_load_balancer_network_load_balancer.api_load_balancer[0].freeform_tags,
      oci_identity_dynamic_group.node_dynamic_group[0].freeform_tags,
      oci_identity_policy.node_policy[0].freeform_tags,
      ] : t == tomap({
        "CostCenter"          = "42"
        "captf_io/cluster"    = "demo"
        "captf_io/namespace"  = "team-a"
        "captf_io/kind"       = "TerraformCluster"
        "captf_io/name"       = "demo"
        "captf_io/managed-by" = "captf"
        "captf_io/template"   = ""
    })])
    error_message = "Every taggable resource must carry the mapped captf tags and additional_tags."
  }
}

run "api_server_port_defaults_without_cluster_network" {
  variables {
    cluster_network = null
  }

  assert {
    condition     = output.control_plane_endpoint.port == 6443
    error_message = "Without cluster_network the API port is 6443."
  }
}

run "node_identity_compartment_wide_opt_in" {
  variables {
    node_identity = { allow_compartment_wide = true }
  }

  assert {
    condition     = oci_identity_dynamic_group.node_dynamic_group[0].matching_rule == "All {instance.compartment.id = 'ocid1.compartment.oc1..aaaaaaaacluster'}"
    error_message = "Without a defined tag, and only with the explicit opt-in, the dynamic group is the compartment."
  }
  assert {
    condition     = length(output.exports.node_defined_tags) == 0 && length(output.exports.control_plane_defined_tags) == 0
    error_message = "Without a defined tag nothing is exported to tag nodes with."
  }
}

run "policy_in_tenancy" {
  variables {
    compartment_id = "ocid1.tenancy.oc1..aaaaaaaatenancy"
  }

  assert {
    condition     = alltrue([for s in oci_identity_policy.node_policy[0].statements : endswith(s, " in tenancy")])
    error_message = "Statements about the root compartment must say \"in tenancy\", not \"in compartment id <tenancy OCID>\"."
  }
}

run "node_identity_byo" {
  variables {
    node_identity = { enabled = false, defined_tag = { namespace = "captf", key = "cluster" } }
    tenancy_id    = null
  }

  assert {
    condition     = length(oci_identity_dynamic_group.node_dynamic_group) == 0 && length(oci_identity_policy.node_policy) == 0
    error_message = "With node_identity.enabled = false no IAM resource is created."
  }
  assert {
    condition     = output.node_dynamic_group_id == null && output.node_policy_id == null
    error_message = "The IAM outputs must be null when the operator manages identity."
  }
  assert {
    condition     = output.exports.node_defined_tags["captf.cluster"] == "team-a/demo"
    error_message = "The defined tag still reaches the nodes, so an operator-managed dynamic group can match it."
  }
  assert {
    condition     = local.home_region == "us-ashburn-1"
    error_message = "Without IAM writes the home provider points at the cluster's region."
  }
}

run "home_region_override" {
  variables {
    home_region = "eu-frankfurt-1"
  }

  assert {
    condition     = local.home_region == "eu-frankfurt-1" && length(data.oci_identity_region_subscriptions.tenancy_regions) == 0
    error_message = "home_region must win without listing the region subscriptions."
  }
}

run "network_compartment_policy" {
  variables {
    network_compartment_id     = "ocid1.compartment.oc1..aaaaaaaanetwork"
    node_policy_compartment_id = "ocid1.tenancy.oc1..aaaaaaaatenancy"
  }

  assert {
    condition     = oci_identity_policy.node_policy[0].compartment_id == "ocid1.tenancy.oc1..aaaaaaaatenancy" && length(oci_identity_policy.node_policy[0].statements) == 6
    error_message = "A VCN in another compartment needs its own virtual-network statement, in a policy attached above both."
  }
  assert {
    condition     = contains(oci_identity_policy.node_policy[0].statements, "Allow dynamic-group id ${oci_identity_dynamic_group.node_dynamic_group[0].id} to use virtual-network-family in compartment id ocid1.compartment.oc1..aaaaaaaanetwork")
    error_message = "The network compartment must be granted virtual-network-family."
  }
}

run "exports_shape" {
  assert {
    condition = sort(keys(output.exports)) == sort([
      "api",
      "compartment_id",
      "control_plane_defined_tags",
      "control_plane_nsg_id",
      "control_plane_subnet_id",
      "failure_domains",
      "node_defined_tags",
      "region",
      "schema",
      "vcn_id",
      "worker_nsg_id",
      "worker_subnet_id",
    ])
    error_message = "exports must hold exactly the keys of schema captf.io/oci-cluster/v1 (README \"Exports\")."
  }
  assert {
    condition     = alltrue([for name, attrs in output.exports.failure_domains : alltrue([for k, v in attrs : contains(["availability_domain", "fault_domain"], k) && can(tostring(v))])])
    error_message = "exports.failure_domains values must be maps of strings: availability_domain and, in fault-domain mode, fault_domain."
  }
  assert {
    condition     = sort(keys(output.exports.api)) == tolist(["host", "kube_apiserver", "network_load_balancer_id", "port"]) && floor(output.exports.api.port) == output.exports.api.port && floor(output.exports.api.kube_apiserver.port) == output.exports.api.kube_apiserver.port
    error_message = "exports.api must hold the endpoint, the load balancer and per listener its backend set and integer port."
  }
  assert {
    condition     = can(jsonencode(output.exports))
    error_message = "exports must serialize to JSON."
  }
}

run "health_failed_load_balancer" {
  plan_options {
    replace = [oci_network_load_balancer_network_load_balancer.api_load_balancer[0]]
  }

  override_resource {
    target = oci_network_load_balancer_network_load_balancer.api_load_balancer
    values = {
      ip_addresses = [
        { ip_address = "10.0.0.10", ip_version = "IPV4", is_public = false, reserved_ip = [] },
      ]
      state = "FAILED"
    }
  }

  assert {
    condition     = output.health.state == "degraded" && !output.health.healthy && output.health.message == "API network load balancer is FAILED" && output.health.reasons == tolist(["LoadBalancerFailed"])
    error_message = "A FAILED load balancer is a degraded cluster with a stable reason."
  }
}

run "health_creating_load_balancer" {
  plan_options {
    replace = [oci_network_load_balancer_network_load_balancer.api_load_balancer[0]]
  }

  override_resource {
    target = oci_network_load_balancer_network_load_balancer.api_load_balancer
    values = {
      ip_addresses = []
      state        = "CREATING"
    }
  }

  assert {
    condition     = output.health.state == "pending" && !output.health.healthy && output.health.reasons == tolist(["LoadBalancerCreating"])
    error_message = "A CREATING load balancer is pending."
  }
  assert {
    condition     = output.control_plane_endpoint == null
    error_message = "No endpoint before the load balancer has an address."
  }
}

run "rke2_listeners" {
  variables {
    distribution = "rke2"
  }

  assert {
    condition     = oci_network_load_balancer_listener.api_listeners["rke2_supervisor"].port == 9345 && oci_network_load_balancer_backend_set.api_backend_sets["rke2_supervisor"].health_checker[0].port == 9345
    error_message = "RKE2 needs a 9345 listener on the same load balancer."
  }
  assert {
    condition     = output.exports.api.kube_apiserver.port == 6443 && output.exports.api.rke2_supervisor.port == 9345 && output.exports.api.rke2_supervisor.backend_set_name == "rke2-supervisor"
    error_message = "Control-plane machines must register in both backend sets."
  }
  assert {
    condition     = contains(keys(oci_core_network_security_group_security_rule.control_plane_nsg_rules), "ingress-tcp-9345-api-load-balancer")
    error_message = "The control-plane NSG must open 9345 from the load balancer."
  }
}

run "user_endpoint_skips_load_balancer" {
  variables {
    control_plane_endpoint = { host = "api.demo.example.com", port = 443 }
  }

  assert {
    condition     = output.control_plane_endpoint == { host = "api.demo.example.com", port = 443 }
    error_message = "A user endpoint must be reported unchanged."
  }
  assert {
    condition     = length(oci_network_load_balancer_network_load_balancer.api_load_balancer) == 0 && length(oci_core_network_security_group.api_load_balancer_nsg) == 0 && length(oci_network_load_balancer_backend_set.api_backend_sets) == 0
    error_message = "A user endpoint must create no load balancer."
  }
  assert {
    condition     = output.exports.api == null && output.api_load_balancer_id == null
    error_message = "exports.api must be null for a user endpoint, so machines register nowhere."
  }
  assert {
    condition     = output.health.state == "running" && output.health.healthy
    error_message = "With a user endpoint there is nothing unhealthy to observe."
  }
  assert {
    condition     = contains(keys(oci_core_network_security_group_security_rule.control_plane_nsg_rules), "ingress-tcp-6443-10.0.0.0/16")
    error_message = "A user endpoint reaches the control plane directly: the API port must be open from the VCN."
  }
}

# A fresh load balancer: the one before was removed by the user endpoint run,
# so the endpoint guard records 8443 rather than refusing the change.
run "api_server_port_override" {
  variables {
    cluster_network = {
      pods            = []
      services        = []
      service_domain  = null
      api_server_port = 8443
    }
  }

  assert {
    condition     = output.control_plane_endpoint.port == 8443 && oci_network_load_balancer_listener.api_listeners["kube_apiserver"].port == 8443
    error_message = "The listener and endpoint must follow cluster_network.api_server_port."
  }
  assert {
    condition     = oci_network_load_balancer_backend_set.api_backend_sets["kube_apiserver"].health_checker[0].port == 8443 && output.exports.api.kube_apiserver.port == 8443 && output.exports.api.port == 8443
    error_message = "Backends and their health checks must use the same port."
  }
  assert {
    condition     = contains(keys(oci_core_network_security_group_security_rule.control_plane_nsg_rules), "ingress-tcp-8443-api-load-balancer")
    error_message = "The control-plane NSG must open the overridden port."
  }
}

# The operator tore the network down: the listings come back empty. A
# refresh, as every destroy runs first, must still succeed; the subnet
# checks are preconditions, which neither a refresh nor a destroy enforces.
# Keep it the file's last run: the test framework's own destroy then runs
# with the network gone too.
run "network_gone_refresh_succeeds" {
  plan_options {
    mode = refresh-only
  }

  override_data {
    target = data.oci_core_subnets.network_subnets
    values = {
      subnets = []
    }
  }
  override_data {
    target = data.oci_core_vcns.network_vcns
    values = {
      virtual_networks = []
    }
  }

  assert {
    condition     = length(data.oci_core_subnets.network_subnets.subnets) == 0 && output.health.state == "running"
    error_message = "With the network gone, the listings return empty and the refresh completes."
  }
}
