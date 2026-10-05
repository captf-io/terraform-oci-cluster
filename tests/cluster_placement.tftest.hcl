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

# Failure domains of the cluster role: which OCI placement a CAPI failure
# domain stands for in each region shape. Mocks and variables are those of
# cluster.tftest.hcl (a three-AD region); runs override the reads.

mock_provider "oci" {
  mock_data "oci_core_subnets" {
    defaults = {
      subnets = [
        { availability_domain = "", cidr_block = "10.0.0.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaacontrolplane", id = "ocid1.subnet.oc1.iad.aaaaaaaacontrolplane", prohibit_public_ip_on_vnic = true, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = true, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
        { availability_domain = "", cidr_block = "10.0.1.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaaworkers", id = "ocid1.subnet.oc1.iad.aaaaaaaaworkers", prohibit_public_ip_on_vnic = true, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = true, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
      ]
    }
  }
  mock_data "oci_core_vcns" {
    defaults = {
      virtual_networks = [
        { cidr_blocks = ["10.0.0.0/16"], compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "vcn", id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", state = "AVAILABLE", byoipv6cidr_blocks = [], byoipv6cidr_details = [], cidr_block = "10.0.0.0/16", default_dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", default_route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", default_security_list_id = "ocid1.securitylist.oc1.iad.aaaaaaaalist", defined_tags = {}, dns_label = "", freeform_tags = {}, ipv6cidr_blocks = [], ipv6private_cidr_blocks = [], is_ipv6enabled = false, is_oracle_gua_allocation_enabled = false, security_attributes = {}, time_created = "2026-01-01 00:00:00 +0000 UTC", vcn_domain_name = "" },
      ]
    }
  }
  mock_data "oci_identity_availability_domains" {
    defaults = {
      availability_domains = [
        { compartment_id = "ocid1.tenancy.oc1..aaaaaaaatenancy", id = "ocid1.availabilitydomain.oc1..ad1", name = "Uocm:US-ASHBURN-AD-1" },
        { compartment_id = "ocid1.tenancy.oc1..aaaaaaaatenancy", id = "ocid1.availabilitydomain.oc1..ad2", name = "Uocm:US-ASHBURN-AD-2" },
        { compartment_id = "ocid1.tenancy.oc1..aaaaaaaatenancy", id = "ocid1.availabilitydomain.oc1..ad3", name = "Uocm:US-ASHBURN-AD-3" },
      ]
    }
  }
  mock_data "oci_identity_fault_domains" {
    defaults = {
      fault_domains = [
        { availability_domain = "Uocm:US-ASHBURN-AD-1", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", id = "ocid1.faultdomain.oc1..fd1", name = "FAULT-DOMAIN-1" },
        { availability_domain = "Uocm:US-ASHBURN-AD-1", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", id = "ocid1.faultdomain.oc1..fd2", name = "FAULT-DOMAIN-2" },
        { availability_domain = "Uocm:US-ASHBURN-AD-1", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", id = "ocid1.faultdomain.oc1..fd3", name = "FAULT-DOMAIN-3" },
      ]
    }
  }
  mock_data "oci_identity_region_subscriptions" {
    defaults = {
      region_subscriptions = [
        { is_home_region = false, region_key = "IAD", region_name = "us-ashburn-1", state = "READY", tenancy_id = "ocid1.tenancy.oc1..aaaaaaaatenancy" },
        { is_home_region = true, region_key = "PHX", region_name = "us-phoenix-1", state = "READY", tenancy_id = "ocid1.tenancy.oc1..aaaaaaaatenancy" },
      ]
    }
  }
  mock_resource "oci_core_network_security_group" {
    defaults = {
      state = "AVAILABLE"
    }
  }
  mock_resource "oci_network_load_balancer_network_load_balancer" {
    defaults = {
      ip_addresses = [
        { ip_address = "10.0.0.10", ip_version = "IPV4", is_public = false, reserved_ip = [] },
      ]
      state = "ACTIVE"
    }
  }
}

mock_provider "oci" {
  alias = "home"

  mock_resource "oci_identity_dynamic_group" {
    defaults = {
      state = "ACTIVE"
    }
  }
  mock_resource "oci_identity_policy" {
    defaults = {
      state = "ACTIVE"
    }
  }
}

variables {
  captf_contract = "v1alpha1"
  captf_cluster  = { name = "demo", namespace = "team-a" }
  captf_object   = { kind = "TerraformCluster", name = "demo", namespace = "team-a" }
  captf_tags = {
    "captf.io/cluster"    = "demo"
    "captf.io/namespace"  = "team-a"
    "captf.io/kind"       = "TerraformCluster"
    "captf.io/name"       = "demo"
    "captf.io/managed-by" = "captf"
    "captf.io/template"   = ""
  }
  control_plane_endpoint    = null
  kubernetes_version        = "v1.34.1"
  control_plane_initialized = false
  cluster_network = {
    pods            = ["192.168.0.0/16"]
    services        = ["10.128.0.0/12"]
    service_domain  = "cluster.local"
    api_server_port = 6443
  }

  compartment_id          = "ocid1.compartment.oc1..aaaaaaaacluster"
  region                  = "us-ashburn-1"
  control_plane_subnet_id = "ocid1.subnet.oc1.iad.aaaaaaaacontrolplane"
  worker_subnet_id        = "ocid1.subnet.oc1.iad.aaaaaaaaworkers"
  tenancy_id              = "ocid1.tenancy.oc1..aaaaaaaatenancy"
  node_identity           = { defined_tag = { namespace = "captf", key = "cluster" } }
}

run "failure_domains_single_availability_domain" {
  command = plan

  override_data {
    target = data.oci_identity_availability_domains.cluster_availability_domains
    values = {
      availability_domains = [
        { compartment_id = "ocid1.tenancy.oc1..aaaaaaaatenancy", id = "ocid1.availabilitydomain.oc1..ad1", name = "Uocm:US-SANJOSE-1-AD-1" },
      ]
    }
  }
  override_data {
    target = data.oci_identity_fault_domains.cluster_fault_domains
    values = {
      fault_domains = [
        { availability_domain = "Uocm:US-SANJOSE-1-AD-1", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", id = "ocid1.faultdomain.oc1..fd1", name = "FAULT-DOMAIN-1" },
        { availability_domain = "Uocm:US-SANJOSE-1-AD-1", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", id = "ocid1.faultdomain.oc1..fd2", name = "FAULT-DOMAIN-2" },
        { availability_domain = "Uocm:US-SANJOSE-1-AD-1", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", id = "ocid1.faultdomain.oc1..fd3", name = "FAULT-DOMAIN-3" },
      ]
    }
  }

  assert {
    condition = output.failure_domains == [
      { name = "FAULT-DOMAIN-1", control_plane = true, attributes = { availability_domain = "Uocm:US-SANJOSE-1-AD-1", fault_domain = "FAULT-DOMAIN-1" } },
      { name = "FAULT-DOMAIN-2", control_plane = true, attributes = { availability_domain = "Uocm:US-SANJOSE-1-AD-1", fault_domain = "FAULT-DOMAIN-2" } },
      { name = "FAULT-DOMAIN-3", control_plane = true, attributes = { availability_domain = "Uocm:US-SANJOSE-1-AD-1", fault_domain = "FAULT-DOMAIN-3" } },
    ]
    error_message = "A single-AD region must spread over the fault domains of its availability domain."
  }
  assert {
    condition     = data.oci_identity_fault_domains.cluster_fault_domains[0].availability_domain == "Uocm:US-SANJOSE-1-AD-1"
    error_message = "The fault domains must be read for the region's one availability domain."
  }
}

run "failure_domains_ad_specific_subnet" {
  command = plan

  override_data {
    target = data.oci_core_subnets.network_subnets
    values = {
      subnets = [
        { availability_domain = "Uocm:US-ASHBURN-AD-2", cidr_block = "10.0.0.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaacontrolplane", id = "ocid1.subnet.oc1.iad.aaaaaaaacontrolplane", prohibit_public_ip_on_vnic = true, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = true, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
        { availability_domain = "", cidr_block = "10.0.1.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaaworkers", id = "ocid1.subnet.oc1.iad.aaaaaaaaworkers", prohibit_public_ip_on_vnic = true, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = true, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
      ]
    }
  }

  assert {
    condition     = local.failure_domain_kind == "fault_domain" && data.oci_identity_fault_domains.cluster_fault_domains[0].availability_domain == "Uocm:US-ASHBURN-AD-2"
    error_message = "An AD-specific subnet confines the cluster to the fault domains of that availability domain."
  }
}

run "failure_domain_mode_fault_domain" {
  command = plan

  variables {
    failure_domain_mode = "fault_domain"
  }

  assert {
    condition     = sort([for fd in output.failure_domains : fd.name]) == tolist(["FAULT-DOMAIN-1", "FAULT-DOMAIN-2", "FAULT-DOMAIN-3"])
    error_message = "failure_domain_mode = fault_domain must use fault domains even in a multi-AD region."
  }
  assert {
    condition     = data.oci_identity_fault_domains.cluster_fault_domains[0].availability_domain == "Uocm:US-ASHBURN-AD-1"
    error_message = "Forced fault-domain mode uses the first availability domain."
  }
}

run "failure_domain_mode_availability_domain" {
  command = plan

  variables {
    failure_domain_mode = "availability_domain"
  }

  override_data {
    target = data.oci_identity_availability_domains.cluster_availability_domains
    values = {
      availability_domains = [
        { compartment_id = "ocid1.tenancy.oc1..aaaaaaaatenancy", id = "ocid1.availabilitydomain.oc1..ad1", name = "Uocm:US-SANJOSE-1-AD-1" },
      ]
    }
  }

  assert {
    condition     = output.failure_domains == [{ name = "US-SANJOSE-1-AD-1", control_plane = true, attributes = { availability_domain = "Uocm:US-SANJOSE-1-AD-1" } }]
    error_message = "failure_domain_mode = availability_domain must use availability domains even in a single-AD region."
  }
  assert {
    condition     = length(data.oci_identity_fault_domains.cluster_fault_domains) == 0
    error_message = "Fault domains are not read in availability-domain mode."
  }
}
