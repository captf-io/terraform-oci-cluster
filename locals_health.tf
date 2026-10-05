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

# Cluster health from the API network load balancer's lifecycle state, never
# from its backends: backends are unhealthy during every normal control-plane
# bring-up (CONVENTIONS.md section 10). States:
# https://docs.oracle.com/en-us/iaas/api/#/en/networkloadbalancer/20200501/NetworkLoadBalancer/
locals {
  # OCI network load balancer lifecycle state -> contract health
  # (common.md "Outputs").
  health_by_state = {
    CREATING = { state = "pending", healthy = false, reason = "LoadBalancerCreating" }
    ACTIVE   = { state = "running", healthy = true, reason = null }
    # Every backend registration updates the load balancer; it keeps serving.
    UPDATING = { state = "running", healthy = true, reason = null }
    FAILED   = { state = "degraded", healthy = false, reason = "LoadBalancerFailed" }
    DELETING = { state = "terminated", healthy = false, reason = "LoadBalancerNotFound" }
    DELETED  = { state = "terminated", healthy = false, reason = "LoadBalancerNotFound" }
  }

  # try(): the provider drops a DELETED load balancer from state on read
  # (ReadResource in internal/tfresource/crud_helpers.go), which leaves no
  # state to read.
  api_load_balancer_state = try(upper(oci_network_load_balancer_network_load_balancer.api_load_balancer[0].state), null)
  health_reading = (
    !local.create_api_load_balancer ? { state = "running", healthy = true, reason = null } :
    local.api_load_balancer_state == null ? { state = "terminated", healthy = false, reason = "LoadBalancerNotFound" } :
    lookup(local.health_by_state, local.api_load_balancer_state, { state = "unknown", healthy = false, reason = "UnknownState" })
  )
  health_message = (
    !local.create_api_load_balancer ? "control-plane endpoint supplied by the user; no load balancer to observe" :
    local.api_load_balancer_state == null ? "API network load balancer not found" :
    "API network load balancer is ${local.api_load_balancer_state}"
  )
}
