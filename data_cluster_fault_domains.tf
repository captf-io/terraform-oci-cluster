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

# The fault domains of one availability domain, read only when they are the
# failure domains: a single-AD region, an AD-specific subnet, or
# failure_domain_mode = fault_domain (locals_placement.tf).
data "oci_identity_fault_domains" "cluster_fault_domains" {
  count = local.failure_domain_kind == "fault_domain" ? 1 : 0

  availability_domain = local.fault_domain_availability_domain
  compartment_id      = var.compartment_id
}
