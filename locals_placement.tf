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

# CAPI failure domains. Availability domains where the region has several;
# otherwise the three fault domains of its one availability domain, as CAPOCI
# does. Names are what the OCI cloud controller manager reports as the zone:
# the AD name after its tenancy prefix (US-ASHBURN-AD-1, mapAvailabilityDomainToFailureDomain in
# https://github.com/oracle/oci-cloud-controller-manager/blob/v1.36.0/pkg/cloudprovider/providers/oci/zones.go),
# or the fault domain name (FAULT-DOMAIN-1).
locals {
  region_availability_domains = sort([for ad in data.oci_identity_availability_domains.cluster_availability_domains.availability_domains : ad.name])
  # An AD-specific subnet only places instances in its own AD.
  subnet_availability_domain = try(local.control_plane_subnet.availability_domain, null)
  usable_availability_domains = (
    local.subnet_availability_domain == null || local.subnet_availability_domain == ""
    ? local.region_availability_domains
    : [local.subnet_availability_domain]
  )

  failure_domain_kind = (
    var.failure_domain_mode != "auto" ? var.failure_domain_mode :
    length(local.usable_availability_domains) > 1 ? "availability_domain" : "fault_domain"
  )
  # Fault domains are those of the first usable AD.
  fault_domain_availability_domain = try(local.usable_availability_domains[0], null)

  # Failure domain name -> where an instance in it goes. fault_domain is null
  # in availability-domain mode: OCI then picks the fault domain.
  failure_domain_placements = local.failure_domain_kind == "availability_domain" ? tomap({
    for ad in local.usable_availability_domains : element(split(":", ad), length(split(":", ad)) - 1) => {
      availability_domain = ad
      fault_domain        = null
    }
    }) : tomap({
    for fd in try(data.oci_identity_fault_domains.cluster_fault_domains[0].fault_domains, []) : fd.name => {
      availability_domain = fd.availability_domain
      fault_domain        = fd.name
    }
  })

  # The contract's attributes are map(string): null fault domains are left out.
  failure_domain_attributes = {
    for name, p in local.failure_domain_placements : name => { for k, v in p : k => v if v != null }
  }
}
