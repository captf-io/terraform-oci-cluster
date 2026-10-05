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

# The availability domains of the region, as the tenancy names them
# (<prefix>:<REGION>-AD-<n>). Any compartment of the tenancy lists them.
data "oci_identity_availability_domains" "cluster_availability_domains" {
  compartment_id = var.compartment_id

  lifecycle {
    postcondition {
      condition     = length(self.availability_domains) > 0
      error_message = "The region lists no availability domains for compartment ${var.compartment_id}: check region and compartment_id."
    }
  }
}
