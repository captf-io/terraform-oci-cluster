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

# Dynamic group of the cluster's control-plane instances, so the OCI cloud
# controller manager and CSI controller running there authenticate as
# instance principals and need no API key in the workload cluster
# (locals_identity.tf). Dynamic groups live in the tenancy (root compartment)
# and are written in the home region.
resource "oci_identity_dynamic_group" "node_dynamic_group" {
  count    = local.node_identity_enabled ? 1 : 0
  provider = oci.home

  compartment_id = local.tenancy_id
  description    = "CAPTF control-plane nodes of cluster ${local.cluster_key}."
  freeform_tags  = local.tags
  matching_rule  = local.node_matching_rule
  name           = local.node_dynamic_group_name

  lifecycle {
    precondition {
      condition     = local.tenancy_id != null
      error_message = "node_identity.enabled needs the tenancy OCID: set spec.variables.tenancy_id, or OCI_TENANCY_OCID in the identity Secret. Or set node_identity.enabled = false and manage the dynamic group yourself."
    }
    precondition {
      condition     = local.node_defined_tag != null || var.node_identity.allow_compartment_wide
      error_message = "node_identity without defined_tag would grant every instance in compartment ${var.compartment_id} (workers and other clusters too) the cloud controller manager's permissions, including reading this cluster's control-plane user data with its CA keys. Set node_identity.defined_tag to an existing tag namespace and key, or node_identity.enabled = false, or accept the risk with node_identity.allow_compartment_wide = true."
    }
  }
}
