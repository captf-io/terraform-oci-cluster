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

# The cluster's exports (schema captf.io/oci-cluster/v1), handed to every
# machine and pool as captf_cluster_outputs (CONVENTIONS.md section 12).
# Adding a key keeps the schema; renaming or removing one bumps it to v2.
# Nothing here is secret: exports are stored in clear.
locals {
  exports = {
    schema                  = "captf.io/oci-cluster/v1"
    region                  = var.region
    compartment_id          = var.compartment_id
    vcn_id                  = local.vcn_id
    control_plane_subnet_id = local.subnet_ids["control_plane"]
    worker_subnet_id        = local.subnet_ids["worker"]
    control_plane_nsg_id    = one(oci_core_network_security_group.control_plane_nsg[*].id)
    worker_nsg_id           = one(oci_core_network_security_group.worker_nsg[*].id)
    failure_domains         = local.failure_domain_attributes
    # Defined tags workers (machines and pools) put on their instances, and
    # the control-plane machines' own, which the node dynamic group matches;
    # both {} without node_identity.defined_tag.
    node_defined_tags          = local.node_defined_tags
    control_plane_defined_tags = local.control_plane_defined_tags
    # The endpoint, and where control-plane machines register (machine.md
    # "Control-plane machines"): per listener its backend set and backend
    # port. Null for a user endpoint.
    api = !local.create_api_load_balancer ? null : merge(
      {
        host                     = local.api_endpoint_host
        port                     = local.api_server_port
        network_load_balancer_id = try(oci_network_load_balancer_network_load_balancer.api_load_balancer[0].id, null)
      },
      { for key, set in oci_network_load_balancer_backend_set.api_backend_sets : key => {
        backend_set_name = set.name
        port             = local.api_listeners[key].backend_port
      } },
    )
  }
}
