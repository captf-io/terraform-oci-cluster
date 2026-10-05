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

# Network security group rules, as maps keyed
# <direction>-<protocol>-<port>-<peer> so adding a rule never replaces the
# others. Ports follow the control-plane checklist:
# https://captf.io/docs/module-author/control-planes/checklist.html
# ("SG / firewall"). Traffic between nodes is open in both directions (etcd,
# kubelet, CNI overlays, RKE2 ports); everything from outside is opt-in.
# Protocol numbers: 1 ICMP, 6 TCP, 17 UDP.
locals {
  nodeport_range = { min = 30000, max = 32767 }

  # Rules every node NSG carries.
  node_common_rules = concat(
    [
      {
        key         = "ingress-all-all-control-plane"
        description = "All traffic from control-plane nodes."
        direction   = "INGRESS"
        protocol    = "all"
        peer        = one(oci_core_network_security_group.control_plane_nsg[*].id)
        peer_type   = "NETWORK_SECURITY_GROUP"
        ports       = null
        icmp        = null
      },
      {
        key         = "ingress-all-all-workers"
        description = "All traffic from worker nodes."
        direction   = "INGRESS"
        protocol    = "all"
        peer        = one(oci_core_network_security_group.worker_nsg[*].id)
        peer_type   = "NETWORK_SECURITY_GROUP"
        ports       = null
        icmp        = null
      },
      {
        key         = "egress-all-all-anywhere"
        description = "All egress: image registries, OCI APIs, package mirrors."
        direction   = "EGRESS"
        protocol    = "all"
        peer        = "0.0.0.0/0"
        peer_type   = "CIDR_BLOCK"
        ports       = null
        icmp        = null
      },
    ],
    # Path MTU discovery: "fragmentation needed" from anywhere in the VCN.
    [for c in local.vcn_cidrs : {
      key         = "ingress-icmp-3.4-${c}"
      description = "ICMP destination unreachable / fragmentation needed (path MTU) from the VCN."
      direction   = "INGRESS"
      protocol    = "1"
      peer        = c
      peer_type   = "CIDR_BLOCK"
      ports       = null
      icmp        = { type = 3, code = 4 }
    }],
    [for c in distinct(var.ssh_allowed_cidrs) : {
      key         = "ingress-tcp-22-${c}"
      description = "SSH from ssh_allowed_cidrs."
      direction   = "INGRESS"
      protocol    = "6"
      peer        = c
      peer_type   = "CIDR_BLOCK"
      ports       = { min = 22, max = 22 }
      icmp        = null
    }],
  )

  control_plane_nsg_rules = { for r in concat(
    local.node_common_rules,
    # Through the load balancer: its NSG is the source, since the backend
    # sets do not preserve the client address (api_backend_sets.tf).
    [for port in local.api_backend_ports : {
      key         = "ingress-tcp-${port}-api-load-balancer"
      description = "API backend port ${port} from the API network load balancer."
      direction   = "INGRESS"
      protocol    = "6"
      peer        = one(oci_core_network_security_group.api_load_balancer_nsg[*].id)
      peer_type   = "NETWORK_SECURITY_GROUP"
      ports       = { min = port, max = port }
      icmp        = null
    } if local.create_api_load_balancer],
    # A user endpoint (kube-vip, an external load balancer) reaches the
    # control plane directly, on the backend ports.
    flatten([for port in local.api_backend_ports : [for c in local.api_source_cidrs : {
      key         = "ingress-tcp-${port}-${c}"
      description = "API backend port ${port} from api_allowed_cidrs and the VCN (user-supplied endpoint)."
      direction   = "INGRESS"
      protocol    = "6"
      peer        = c
      peer_type   = "CIDR_BLOCK"
      ports       = { min = port, max = port }
      icmp        = null
    }] if !local.create_api_load_balancer]),
  ) : r.key => r }

  worker_nsg_rules = { for r in concat(
    local.node_common_rules,
    flatten([for c in distinct(var.nodeport_allowed_cidrs) : [for p in ["6", "17"] : {
      key         = "ingress-${p == "6" ? "tcp" : "udp"}-${local.nodeport_range.min}-${local.nodeport_range.max}-${c}"
      description = "NodePort Services from nodeport_allowed_cidrs."
      direction   = "INGRESS"
      protocol    = p
      peer        = c
      peer_type   = "CIDR_BLOCK"
      ports       = local.nodeport_range
      icmp        = null
    }]]),
  ) : r.key => r }

  api_load_balancer_nsg_rules = !local.create_api_load_balancer ? {} : { for r in concat(
    flatten([for l in local.api_listeners : [for c in local.api_source_cidrs : {
      key         = "ingress-tcp-${l.port}-${c}"
      description = "API port ${l.port} from the VCN and api_allowed_cidrs."
      direction   = "INGRESS"
      protocol    = "6"
      peer        = c
      peer_type   = "CIDR_BLOCK"
      ports       = { min = l.port, max = l.port }
      icmp        = null
    }]]),
    [for port in local.api_backend_ports : {
      key         = "egress-tcp-${port}-control-plane"
      description = "API backend port ${port} and its health checks to control-plane nodes."
      direction   = "EGRESS"
      protocol    = "6"
      peer        = one(oci_core_network_security_group.control_plane_nsg[*].id)
      peer_type   = "NETWORK_SECURITY_GROUP"
      ports       = { min = port, max = port }
      icmp        = null
    }],
  ) : r.key => r }
}
