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

# Node identity: the dynamic group's matching rule and the policy that lets
# the OCI cloud controller manager and CSI controller act as the control-plane
# nodes they run on (instance principals). Only control-plane instances are
# matched: the policy can read every instance's metadata, and a control-plane
# instance's user data holds the cluster's CA keys, which workers must never
# reach (control-planes/checklist.md, "CP bootstrap payload size and
# secrecy"). Rule syntax:
# https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm
locals {
  node_identity_enabled = var.node_identity.enabled
  node_defined_tag      = var.node_identity.defined_tag

  # The identity's credential files are mounted here; OCI_TENANCY_OCID is a
  # plain identifier the API-key identity already carries, so the tenancy is
  # not asked for twice.
  tenancy_file = "/var/run/captf/credentials/OCI_TENANCY_OCID"
  tenancy_id   = var.tenancy_id != null ? var.tenancy_id : try(trimspace(file(local.tenancy_file)), null)

  # The values machines and pools give the defined tag: unique per cluster,
  # and distinct for control-plane machines, which alone the group matches.
  node_defined_tags = try({
    "${local.node_defined_tag.namespace}.${local.node_defined_tag.key}" = local.cluster_key
  }, {})
  control_plane_defined_tags = try({
    "${local.node_defined_tag.namespace}.${local.node_defined_tag.key}" = "${local.cluster_key}/control-plane"
  }, {})

  # Dynamic groups match instances by compartment, OCID or defined tag, never
  # by free-form tag. Without a defined tag the group is every instance in
  # the compartment, workers and other clusters included, so it needs
  # node_identity.allow_compartment_wide (node_dynamic_group.tf).
  node_matching_rule = try(
    "All {instance.compartment.id = '${var.compartment_id}', tag.${local.node_defined_tag.namespace}.${local.node_defined_tag.key}.value = '${local.cluster_key}/control-plane'}",
    "All {instance.compartment.id = '${var.compartment_id}'}",
  )

  node_policy_compartment_id = coalesce(var.node_policy_compartment_id, var.compartment_id)
  # The VCN may live in a network compartment of its own; the cloud
  # controller manager needs it for load balancer subnets and security lists.
  network_compartment_ids = distinct([var.compartment_id, local.network_compartment_id])

  # What the OCI cloud controller manager (nodes, Services of type
  # LoadBalancer) and the block volume CSI driver need. The first three verbs
  # are the CCM's documented instance-principal policy:
  # https://github.com/oracle/oci-cloud-controller-manager/blob/v1.36.0/manifests/provider-config-instance-principals-example.yaml
  # Network load balancer Services and CSI volumes add the other two. No
  # "manage security-lists": run the CCM with securityListManagementMode None
  # and open NodePorts through nodeport_allowed_cidrs (README "Limitations").
  # try(): without node identity there is no group to grant to.
  node_policy_statements = try(concat(
    [for verb in ["read instance-family", "manage load-balancers", "manage network-load-balancers", "manage volume-family"] :
    "Allow dynamic-group id ${local.node_dynamic_group_id} to ${verb} in ${local.policy_locations[var.compartment_id]}"],
    [for c in local.network_compartment_ids : "Allow dynamic-group id ${local.node_dynamic_group_id} to use virtual-network-family in ${local.policy_locations[c]}"],
  ), [])
  # The root compartment is "tenancy" in a policy statement, never
  # "compartment id <tenancy OCID>".
  policy_locations      = { for c in local.network_compartment_ids : c => startswith(c, "ocid1.tenancy.") ? "tenancy" : "compartment id ${c}" }
  node_dynamic_group_id = try(oci_identity_dynamic_group.node_dynamic_group[0].id, null)

  # IAM writes go to the home region. Without node identity there are none,
  # and the alias simply points at the cluster's region.
  home_region = coalesce(
    var.home_region,
    try(one([for s in data.oci_identity_region_subscriptions.tenancy_regions[0].region_subscriptions : s.region_name if s.is_home_region]), null),
    var.region,
  )
}
