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

# Network security group of the control-plane nodes; machines attach their
# VNICs to it (exports.control_plane_nsg_id). It always exists, so the
# cluster's cross-variable checks live here; count = 1 so exports read null,
# not unknown, if it vanishes (CONVENTIONS.md section 9).
resource "oci_core_network_security_group" "control_plane_nsg" {
  count = 1

  compartment_id = var.compartment_id
  display_name   = local.control_plane_nsg_name
  freeform_tags  = local.tags
  vcn_id         = local.nsg_vcn_id

  lifecycle {
    precondition {
      condition     = length(local.tags) <= 10
      error_message = "OCI allows 10 free-form tags per resource; captf_tags and additional_tags together hold ${length(local.tags)}. Remove entries from additional_tags."
    }
    precondition {
      condition     = length(local.cluster_subnets) == length(local.subnet_ids)
      error_message = "The subnets ${join(", ", [for role, id in local.subnet_ids : id if !contains(keys(local.cluster_subnets), role)])} are not in compartment ${local.network_compartment_id}: set network_compartment_id to the compartment of the VCN and its subnets."
    }
    precondition {
      condition     = local.cluster_vcn != null
      error_message = "The VCN of the control-plane subnet is not in compartment ${local.network_compartment_id}: set network_compartment_id to the compartment of the VCN and its subnets."
    }
    precondition {
      condition     = alltrue([for s in local.cluster_subnets : s.vcn_id == local.vcn_id])
      error_message = "control_plane_subnet_id, worker_subnet_id and api_load_balancer_subnet_id must all be in one VCN."
    }
    precondition {
      condition     = alltrue([for s in local.cluster_subnets : upper(s.state) == "AVAILABLE"])
      error_message = "Every subnet of the cluster must be AVAILABLE; found ${join(", ", [for role, s in local.cluster_subnets : "${role} ${s.state}"])}."
    }
    precondition {
      condition     = alltrue([for s in local.cluster_subnets : coalesce(s.availability_domain, "-") == "-" || s.availability_domain == local.subnet_availability_domain])
      error_message = "An AD-specific worker or load balancer subnet must be in the control-plane subnet's availability domain, which must then be AD-specific too: instances in other availability domains could not launch into it. Use regional subnets."
    }
    precondition {
      condition     = !(var.distribution == "rke2" && local.api_server_port == 9345)
      error_message = "cluster_network.api_server_port cannot be 9345 with distribution rke2: the RKE2 supervisor listens on 9345 on the same address."
    }
    precondition {
      condition     = length(local.failure_domain_placements) > 0
      error_message = "No failure domains found for failure_domain_mode ${var.failure_domain_mode}: check region and compartment_id."
    }
  }
}
