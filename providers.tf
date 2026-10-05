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

# The OCI providers. Credentials come only from the identity, as OCI_*
# environment variables and files under /var/run/captf/credentials (the
# runner drops TF_VAR_*): README "Identity Secret". The region is the
# cluster's, never the identity's.

provider "oci" {
  ignore_defined_tags = local.ignore_defined_tags
  region              = var.region
}

# IAM writes (the node dynamic group and policy) must go to the tenancy's
# home region:
# https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingregions.htm
provider "oci" {
  alias = "home"

  ignore_defined_tags = local.ignore_defined_tags
  region              = local.home_region
}
