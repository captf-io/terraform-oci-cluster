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

# The tenancy's region subscriptions, read to find the home region for IAM
# writes. Skipped when home_region is set, node identity is off, or the
# tenancy is unknown (node_dynamic_group.tf then fails with a clear message).
data "oci_identity_region_subscriptions" "tenancy_regions" {
  count = local.node_identity_enabled && var.home_region == null && local.tenancy_id != null ? 1 : 0

  tenancy_id = local.tenancy_id
}
