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

# The operator's network and the API endpoint the module builds on it.
locals {
  # A non-null control_plane_endpoint input means someone else owns the
  # endpoint (cluster.md "control_plane_endpoint (input)"): no load balancer.
  create_api_load_balancer = var.control_plane_endpoint == null

  # Role -> subnet. Workers and the load balancer default to the
  # control-plane subnet; the load balancer's is checked only when it exists.
  subnet_ids = { for role, id in {
    control_plane     = var.control_plane_subnet_id
    worker            = var.worker_subnet_id != null ? var.worker_subnet_id : var.control_plane_subnet_id
    api_load_balancer = local.create_api_load_balancer ? (var.api_load_balancer_subnet_id != null ? var.api_load_balancer_subnet_id : var.control_plane_subnet_id) : null
  } : role => id if id != null }

  # Where the VCN and the subnets live (data_network_subnets.tf).
  network_compartment_id = var.network_compartment_id != null ? var.network_compartment_id : var.compartment_id

  # Every subnet the cluster uses that the listing found, by role, for the
  # checks on control_plane_nsg.tf. A role is missing when its subnet is not
  # in the network compartment, or is gone.
  network_subnets_by_id = { for s in data.oci_core_subnets.network_subnets.subnets : s.id => s }
  cluster_subnets = {
    for role, id in local.subnet_ids : role => local.network_subnets_by_id[id]
    if contains(keys(local.network_subnets_by_id), id)
  }
  control_plane_subnet     = try(local.cluster_subnets["control_plane"], null)
  api_load_balancer_subnet = try(local.cluster_subnets["api_load_balancer"], null)

  # The control-plane subnet's VCN is the cluster's.
  vcn_id = try(local.control_plane_subnet.vcn_id, null)
  # The NSGs' vcn_id: a placeholder once the network is gone, because a
  # destroy still evaluates every required argument (OpenTofu's does). Any
  # other plan stops at the subnet preconditions first, so the placeholder
  # never reaches the API.
  nsg_vcn_id  = local.vcn_id != null ? local.vcn_id : "ocid1.vcn.oc1..network-not-found"
  cluster_vcn = try([for v in data.oci_core_vcns.network_vcns.virtual_networks : v if v.id == local.vcn_id][0], null)
  vcn_cidrs   = try(sort(local.cluster_vcn.cidr_blocks), [])

  # The endpoint port: cluster_network.api_server_port (default 6443).
  api_server_port = coalesce(try(var.cluster_network.api_server_port, null), 6443)

  # Listener key -> endpoint port and backend port (CONVENTIONS.md section
  # 12). With kubeadm the backend port is the endpoint port, kept equal to
  # the bindPort by convention (cluster.md "cluster_network (input)"); RKE2's
  # kube-apiserver always listens on 6443, and its supervisor on 9345 on the
  # same address (control-planes/rke2.md).
  api_listeners = merge(
    {
      kube_apiserver = {
        port         = local.api_server_port
        backend_port = var.distribution == "rke2" ? 6443 : local.api_server_port
      }
    },
    var.distribution == "rke2" ? { rke2_supervisor = { port = 9345, backend_port = 9345 } } : {},
  )
  api_backend_ports = distinct([for l in local.api_listeners : l.backend_port])
  # Who may reach the endpoint: the VCN itself (nodes, and a management
  # cluster peered into it) and the operator's list.
  api_source_cidrs = distinct(concat(local.vcn_cidrs, var.api_allowed_cidrs))

  # The endpoint host: the load balancer's public IPv4 address when it is
  # public, else its private one. try(): it may have vanished after a refresh.
  api_endpoint_host = try([
    for ip in oci_network_load_balancer_network_load_balancer.api_load_balancer[0].ip_addresses : ip.ip_address
    if ip.is_public == var.api_load_balancer_public && upper(coalesce(ip.ip_version, "IPV4")) == "IPV4"
  ][0], null)
}
