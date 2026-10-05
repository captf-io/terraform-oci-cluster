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

# The API endpoint: a network load balancer in front of the control-plane
# nodes, private unless api_load_balancer_public. Its address becomes
# Cluster.spec.controlPlaneEndpoint and must never change
# (cluster.md "control_plane_endpoint (output)"). is_private, subnet_id and
# the pinned addresses force a replacement, which the controller's
# destructive-plan guard holds for approval.
resource "oci_network_load_balancer_network_load_balancer" "api_load_balancer" {
  count = local.create_api_load_balancer ? 1 : 0

  assigned_private_ipv4      = var.api_load_balancer_private_ip
  compartment_id             = var.compartment_id
  display_name               = local.api_load_balancer_name
  freeform_tags              = local.tags
  is_private                 = !var.api_load_balancer_public
  network_security_group_ids = [oci_core_network_security_group.api_load_balancer_nsg[0].id]
  subnet_id                  = local.subnet_ids["api_load_balancer"]

  dynamic "reserved_ips" {
    for_each = var.api_load_balancer_public && var.api_load_balancer_reserved_public_ip_id != null ? [var.api_load_balancer_reserved_public_ip_id] : []

    content {
      id = reserved_ips.value
    }
  }

  lifecycle {
    precondition {
      condition     = !var.api_load_balancer_public || length(var.api_allowed_cidrs) > 0
      error_message = "api_load_balancer_public is true but api_allowed_cidrs is empty: list the CIDRs allowed to reach the API (the management cluster's egress and the NAT gateway's public IP for nodes in private subnets)."
    }
    precondition {
      condition     = !(var.api_load_balancer_public && try(local.api_load_balancer_subnet.prohibit_public_ip_on_vnic, false))
      error_message = "api_load_balancer_public is true but the load balancer subnet ${local.subnet_ids["api_load_balancer"]} prohibits public IPs: set api_load_balancer_subnet_id to a public subnet."
    }
    precondition {
      condition     = var.api_load_balancer_reserved_public_ip_id == null || var.api_load_balancer_public
      error_message = "api_load_balancer_reserved_public_ip_id is set but api_load_balancer_public is false: a reserved public IP only applies to a public load balancer."
    }
  }
}
