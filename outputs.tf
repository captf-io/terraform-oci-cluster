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

# Contract outputs of the cluster role, in contract order:
# https://captf.io/docs/module-author/contract/v1alpha1/cluster.html#outputs
# and common.md "Outputs" (health).

output "control_plane_endpoint" {
  description = "The API endpoint: the user's when one was given, else the network load balancer's IPv4 address (public or private, per api_load_balancer_public) and the API port. Stable for the life of the cluster unless the load balancer is replaced."
  value = var.control_plane_endpoint != null ? var.control_plane_endpoint : (
    local.api_endpoint_host == null ? null : {
      host = local.api_endpoint_host
      port = local.api_server_port
    }
  )
}

output "failure_domains" {
  description = "The CAPI failure domains: availability domains, or the fault domains of one availability domain (failure_domain_mode). All accept control-plane machines."
  value = [for name in sort(keys(local.failure_domain_attributes)) : {
    name          = name
    control_plane = true
    attributes    = local.failure_domain_attributes[name]
  }]
}

output "exports" {
  description = "Cluster values for machines and pools (captf_cluster_outputs), schema captf.io/oci-cluster/v1: README \"Exports\"."
  value       = local.exports
}

output "health" {
  description = "Cluster health from the API network load balancer's lifecycle state (common.md \"Outputs\")."
  value = {
    state   = local.health_reading.state
    healthy = local.health_reading.healthy
    message = local.health_message
    reasons = local.health_reading.healthy ? [] : [local.health_reading.reason]
  }
}
