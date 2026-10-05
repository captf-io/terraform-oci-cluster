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

# Pins every input that decides the API endpoint once the load balancer
# exists (CONVENTIONS.md section 12): CAPI copies the endpoint once and never
# updates it, a port change would update the listener in place, and CAPTF's
# destructive-plan guard catches replacements only, which an operator can
# approve. The observed address is recorded for diagnosis.
resource "terraform_data" "api_endpoint_guard" {
  count = local.create_api_load_balancer ? 1 : 0

  input = {
    api_load_balancer_public                = var.api_load_balancer_public
    api_load_balancer_subnet_id             = local.subnet_ids["api_load_balancer"]
    api_load_balancer_private_ip            = var.api_load_balancer_private_ip
    api_load_balancer_reserved_public_ip_id = var.api_load_balancer_reserved_public_ip_id
    api_server_port                         = local.api_server_port
    address                                 = local.api_endpoint_host
  }

  lifecycle {
    ignore_changes = [input]

    postcondition {
      condition     = self.input.api_load_balancer_public == var.api_load_balancer_public
      error_message = "The API endpoint of this cluster is fixed once its load balancer exists: api_load_balancer_public cannot change (recorded ${self.input.api_load_balancer_public}, requested ${var.api_load_balancer_public}). Revert the change, or create a new cluster."
    }
    postcondition {
      condition     = self.input.api_load_balancer_subnet_id == local.subnet_ids["api_load_balancer"]
      error_message = "The API endpoint of this cluster is fixed once its load balancer exists: api_load_balancer_subnet_id cannot change (recorded ${self.input.api_load_balancer_subnet_id}, requested ${local.subnet_ids["api_load_balancer"]}). Revert the change, or create a new cluster."
    }
    postcondition {
      condition     = self.input.api_load_balancer_private_ip == var.api_load_balancer_private_ip
      error_message = "The API endpoint of this cluster is fixed once its load balancer exists: api_load_balancer_private_ip cannot change (recorded ${coalesce(self.input.api_load_balancer_private_ip, "none")}, requested ${coalesce(var.api_load_balancer_private_ip, "none")}). Revert the change, or create a new cluster."
    }
    postcondition {
      condition     = self.input.api_load_balancer_reserved_public_ip_id == var.api_load_balancer_reserved_public_ip_id
      error_message = "The API endpoint of this cluster is fixed once its load balancer exists: api_load_balancer_reserved_public_ip_id cannot change (recorded ${coalesce(self.input.api_load_balancer_reserved_public_ip_id, "none")}, requested ${coalesce(var.api_load_balancer_reserved_public_ip_id, "none")}). Revert the change, or create a new cluster."
    }
    postcondition {
      condition     = self.input.api_server_port == local.api_server_port
      error_message = "The API endpoint of this cluster is fixed once its load balancer exists: cluster_network.api_server_port cannot change (recorded ${self.input.api_server_port}, requested ${local.api_server_port}). Revert the change, or create a new cluster."
    }
  }
}
