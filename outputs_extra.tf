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

# Non-contract outputs, alphabetical. The controller never reads them; they
# help operators wire what the module leaves to them (the cloud controller
# manager's configuration, extra IAM policies).

output "api_load_balancer_id" {
  description = "OCID of the API network load balancer; null with a user-supplied endpoint."
  value       = try(oci_network_load_balancer_network_load_balancer.api_load_balancer[0].id, null)
}

output "node_dynamic_group_id" {
  description = "OCID of the node dynamic group, for extra policy statements (\"Allow dynamic-group id <ocid> to ...\"); null when node_identity.enabled is false."
  value       = try(oci_identity_dynamic_group.node_dynamic_group[0].id, null)
}

output "node_policy_id" {
  description = "OCID of the node policy; null when node_identity.enabled is false."
  value       = try(oci_identity_policy.node_policy[0].id, null)
}
