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

# One TCP listener per API port, on the same address: RKE2 joins through
# <endpoint host>:9345 (cluster.md "Control-plane provider requirements").
resource "oci_network_load_balancer_listener" "api_listeners" {
  for_each = oci_network_load_balancer_backend_set.api_backend_sets

  default_backend_set_name = each.value.name
  name                     = each.value.name
  network_load_balancer_id = each.value.network_load_balancer_id
  port                     = local.api_listeners[each.key].port
  protocol                 = "TCP"
}
