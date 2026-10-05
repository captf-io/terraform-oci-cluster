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

# Rules of the worker NSG, one per key of local.worker_nsg_rules
# (locals_security_rules.tf). Stateful: replies need no rule of their own.
resource "oci_core_network_security_group_security_rule" "worker_nsg_rules" {
  for_each = local.worker_nsg_rules

  description               = each.value.description
  destination               = each.value.direction == "EGRESS" ? each.value.peer : null
  destination_type          = each.value.direction == "EGRESS" ? each.value.peer_type : null
  direction                 = each.value.direction
  network_security_group_id = oci_core_network_security_group.worker_nsg[0].id
  protocol                  = each.value.protocol
  source                    = each.value.direction == "INGRESS" ? each.value.peer : null
  source_type               = each.value.direction == "INGRESS" ? each.value.peer_type : null
  stateless                 = false

  dynamic "icmp_options" {
    for_each = each.value.icmp == null ? [] : [each.value.icmp]

    content {
      code = icmp_options.value.code
      type = icmp_options.value.type
    }
  }

  dynamic "tcp_options" {
    for_each = each.value.protocol == "6" && each.value.ports != null ? [each.value.ports] : []

    content {
      destination_port_range {
        max = tcp_options.value.max
        min = tcp_options.value.min
      }
    }
  }

  dynamic "udp_options" {
    for_each = each.value.protocol == "17" && each.value.ports != null ? [each.value.ports] : []

    content {
      destination_port_range {
        max = udp_options.value.max
        min = udp_options.value.min
      }
    }
  }
}
