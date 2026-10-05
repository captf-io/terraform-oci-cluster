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

# Cloud resource names, derived from the Cluster's namespace and name with a
# hash that keeps truncated names unique (CONVENTIONS.md section 6).
locals {
  cluster_key  = "${var.captf_cluster.namespace}/${var.captf_cluster.name}"
  cluster_hash = substr(sha256(local.cluster_key), 0, 8)
  # OCI IAM names (dynamic groups, policies) allow 100 characters, the
  # tightest limit here; 20 are kept for the role suffixes below.
  name_max = 80
  # name_max - 9 leaves room for "-" and the hash.
  name_prefix = "${trimsuffix(substr(lower("captf-${var.captf_cluster.namespace}-${var.captf_cluster.name}"), 0, local.name_max - 9), "-")}-${local.cluster_hash}"

  api_load_balancer_name     = "${local.name_prefix}-api"
  control_plane_nsg_name     = "${local.name_prefix}-control-plane"
  worker_nsg_name            = "${local.name_prefix}-workers"
  api_load_balancer_nsg_name = "${local.name_prefix}-api-lb"
  node_dynamic_group_name    = "${local.name_prefix}-control-plane"
  node_policy_name           = "${local.name_prefix}-control-plane"
}
