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

# The subnets of the network compartment, listed rather than read one by
# one: a listing returns empty once the operator's network is gone, where a
# read of a deleted subnet fails, so a destroy still finishes
# (CONVENTIONS.md section 9). locals_network.tf picks the cluster's subnets
# by OCID; their checks are preconditions on control_plane_nsg.tf, which a
# destroy skips.
data "oci_core_subnets" "network_subnets" {
  compartment_id = local.network_compartment_id
}
