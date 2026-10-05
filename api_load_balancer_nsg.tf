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

# Network security group of the API network load balancer: the only way in
# to the control plane's API ports (locals_security_rules.tf).
resource "oci_core_network_security_group" "api_load_balancer_nsg" {
  count = local.create_api_load_balancer ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = local.api_load_balancer_nsg_name
  freeform_tags  = local.tags
  vcn_id         = local.nsg_vcn_id
}
