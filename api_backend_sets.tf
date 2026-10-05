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

# One backend set per API listener (kube-apiserver, and rke2-supervisor with
# RKE2). Control-plane machines add themselves as backends in their own
# state (machine.md "Control-plane machines"). The backends see the load
# balancer as the client (is_preserve_source = false), which is what lets a
# control-plane node reach itself through the endpoint (cluster.md "Hairpin
# reachability"); CAPOCI configures its API load balancer the same way.
resource "oci_network_load_balancer_backend_set" "api_backend_sets" {
  for_each = local.create_api_load_balancer ? local.api_listeners : {}

  is_preserve_source       = false
  name                     = replace(each.key, "_", "-")
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.api_load_balancer[0].id
  policy                   = "FIVE_TUPLE"

  # TCP connects go green with a single backend during kubeadm init, and need
  # no anonymous auth (control-plane checklist, "Health checks").
  health_checker {
    port     = each.value.backend_port
    protocol = "TCP"
  }
}
