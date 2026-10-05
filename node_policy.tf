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

# What the node dynamic group may do (locals_identity.tf). Attached to the
# cluster's compartment unless node_policy_compartment_id names an ancestor,
# and written in the home region.
resource "oci_identity_policy" "node_policy" {
  count    = local.node_identity_enabled ? 1 : 0
  provider = oci.home

  compartment_id = local.node_policy_compartment_id
  description    = "Lets the CAPTF control-plane nodes of cluster ${local.cluster_key} run the OCI cloud controller manager and CSI controller."
  freeform_tags  = local.tags
  name           = local.node_policy_name
  statements     = local.node_policy_statements

  lifecycle {
    precondition {
      condition     = length(local.network_compartment_ids) == 1 || var.node_policy_compartment_id != null
      error_message = "The network is in compartment ${local.network_compartment_id}, not ${var.compartment_id}: set node_policy_compartment_id to a compartment above both (the tenancy works), since a policy only governs its own compartment and those below it."
    }
  }
}
