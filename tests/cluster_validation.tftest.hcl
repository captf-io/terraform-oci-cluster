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

# Every variable validation and every precondition of the cluster role
# fails the plan with its own message: one run per check, named
# invalid_<variable> or rejects_<condition> (CONVENTIONS.md section 14).
# Mocks and variables are those of cluster.tftest.hcl.

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

run "invalid_captf_contract" {
  command = plan

  variables {
    captf_contract = "v1alpha2"
  }

  expect_failures = [var.captf_contract]
}

run "invalid_additional_tags_count" {
  command = plan

  variables {
    additional_tags = { a = "1", b = "2", c = "3", d = "4", e = "5" }
  }

  expect_failures = [var.additional_tags]
}

run "invalid_additional_tags_key" {
  command = plan

  variables {
    additional_tags = { "cost.center" = "42" }
  }

  expect_failures = [var.additional_tags]
}

run "invalid_additional_tags_reserved" {
  command = plan

  variables {
    additional_tags = { "CAPTF_IO/cluster" = "other" }
  }

  expect_failures = [var.additional_tags]
}

run "invalid_api_allowed_cidrs" {
  command = plan

  variables {
    api_allowed_cidrs = ["203.0.113.0"]
  }

  expect_failures = [var.api_allowed_cidrs]
}

run "invalid_api_load_balancer_private_ip" {
  command = plan

  variables {
    api_load_balancer_private_ip = "10.0.0.300"
  }

  expect_failures = [var.api_load_balancer_private_ip]
}

run "invalid_api_load_balancer_reserved_public_ip_id" {
  command = plan

  variables {
    api_load_balancer_reserved_public_ip_id = "198.51.100.7"
  }

  expect_failures = [var.api_load_balancer_reserved_public_ip_id]
}

run "invalid_api_load_balancer_subnet_id" {
  command = plan

  variables {
    api_load_balancer_subnet_id = "subnet-123"
  }

  expect_failures = [var.api_load_balancer_subnet_id]
}

run "invalid_compartment_id" {
  command = plan

  variables {
    compartment_id = null
  }

  expect_failures = [var.compartment_id]
}

run "invalid_control_plane_subnet_id" {
  command = plan

  variables {
    control_plane_subnet_id = null
  }

  expect_failures = [var.control_plane_subnet_id]
}

run "invalid_failure_domain_mode" {
  command = plan

  variables {
    failure_domain_mode = "zone"
  }

  expect_failures = [var.failure_domain_mode]
}

run "invalid_home_region" {
  command = plan

  variables {
    home_region = "Ashburn"
  }

  expect_failures = [var.home_region]
}

run "invalid_ignore_defined_tags" {
  command = plan

  variables {
    ignore_defined_tags = ["CreatedBy"]
  }

  expect_failures = [var.ignore_defined_tags]
}

run "invalid_node_identity" {
  command = plan

  variables {
    node_identity = { defined_tag = { namespace = "captf.io", key = "cluster" } }
  }

  expect_failures = [var.node_identity]
}

run "invalid_node_policy_compartment_id" {
  command = plan

  variables {
    node_policy_compartment_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn"
  }

  expect_failures = [var.node_policy_compartment_id]
}

run "invalid_nodeport_allowed_cidrs" {
  command = plan

  variables {
    nodeport_allowed_cidrs = ["any"]
  }

  expect_failures = [var.nodeport_allowed_cidrs]
}

run "invalid_region" {
  command = plan

  variables {
    region = null
  }

  expect_failures = [var.region]
}

run "invalid_ssh_allowed_cidrs" {
  command = plan

  variables {
    ssh_allowed_cidrs = ["10.0.0.0/33"]
  }

  expect_failures = [var.ssh_allowed_cidrs]
}

run "invalid_tenancy_id" {
  command = plan

  variables {
    tenancy_id = "ocid1.compartment.oc1..aaaaaaaacluster"
  }

  expect_failures = [var.tenancy_id]
}

run "invalid_worker_subnet_id" {
  command = plan

  variables {
    worker_subnet_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn"
  }

  expect_failures = [var.worker_subnet_id]
}

run "rejects_too_many_tags" {
  command = plan

  variables {
    captf_tags = {
      "captf.io/cluster"    = "demo"
      "captf.io/namespace"  = "team-a"
      "captf.io/kind"       = "TerraformCluster"
      "captf.io/name"       = "demo"
      "captf.io/managed-by" = "captf"
      "captf.io/template"   = ""
      "captf.io/future"     = "x"
    }
    additional_tags = { a = "1", b = "2", c = "3", d = "4" }
  }

  expect_failures = [oci_core_network_security_group.control_plane_nsg]
}

run "rejects_subnets_in_different_vcns" {
  command = plan

  override_data {
    target = data.oci_core_subnets.network_subnets
    values = {
      subnets = [
        { availability_domain = "", cidr_block = "10.0.0.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaacontrolplane", id = "ocid1.subnet.oc1.iad.aaaaaaaacontrolplane", prohibit_public_ip_on_vnic = true, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = true, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
        { availability_domain = "", cidr_block = "10.0.1.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaaworkers", id = "ocid1.subnet.oc1.iad.aaaaaaaaworkers", prohibit_public_ip_on_vnic = true, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaaother", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = true, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
      ]
    }
  }

  expect_failures = [oci_core_network_security_group.control_plane_nsg]
}

run "rejects_no_failure_domains" {
  command = plan

  variables {
    failure_domain_mode = "fault_domain"
  }

  override_data {
    target = data.oci_identity_fault_domains.cluster_fault_domains
    values = {
      fault_domains = []
    }
  }

  expect_failures = [oci_core_network_security_group.control_plane_nsg]
}

run "public_requires_allowed_cidrs" {
  command = plan

  variables {
    api_load_balancer_public = true
  }

  override_data {
    target = data.oci_core_subnets.network_subnets
    values = {
      subnets = [
        { availability_domain = "", cidr_block = "10.0.0.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaacontrolplane", id = "ocid1.subnet.oc1.iad.aaaaaaaacontrolplane", prohibit_public_ip_on_vnic = false, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = false, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
        { availability_domain = "", cidr_block = "10.0.1.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaaworkers", id = "ocid1.subnet.oc1.iad.aaaaaaaaworkers", prohibit_public_ip_on_vnic = true, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = true, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
      ]
    }
  }

  expect_failures = [oci_network_load_balancer_network_load_balancer.api_load_balancer]
}

run "rejects_reserved_ip_on_private_load_balancer" {
  command = plan

  variables {
    api_load_balancer_reserved_public_ip_id = "ocid1.publicip.oc1.iad.aaaaaaaareserved"
  }

  expect_failures = [oci_network_load_balancer_network_load_balancer.api_load_balancer]
}

run "rejects_private_subnet_for_public_load_balancer" {
  command = plan

  variables {
    api_load_balancer_public = true
    api_allowed_cidrs        = ["203.0.113.0/24"]
  }

  expect_failures = [oci_network_load_balancer_network_load_balancer.api_load_balancer]
}

run "rejects_unavailable_subnet" {
  command = plan

  override_data {
    target = data.oci_core_subnets.network_subnets
    values = {
      subnets = [
        { availability_domain = "", cidr_block = "10.0.0.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaacontrolplane", id = "ocid1.subnet.oc1.iad.aaaaaaaacontrolplane", prohibit_public_ip_on_vnic = true, state = "TERMINATED", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = true, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
        { availability_domain = "", cidr_block = "10.0.1.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaaworkers", id = "ocid1.subnet.oc1.iad.aaaaaaaaworkers", prohibit_public_ip_on_vnic = true, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = true, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
      ]
    }
  }

  expect_failures = [oci_core_network_security_group.control_plane_nsg]
}

run "rejects_region_without_availability_domains" {
  command = plan

  override_data {
    target = data.oci_identity_availability_domains.cluster_availability_domains
    values = {
      availability_domains = []
    }
  }

  expect_failures = [data.oci_identity_availability_domains.cluster_availability_domains]
}

run "rejects_missing_tenancy" {
  command = plan

  variables {
    tenancy_id = null
  }

  expect_failures = [oci_identity_dynamic_group.node_dynamic_group]
}

run "rejects_vcn_in_other_compartment" {
  command = plan

  variables {
    network_compartment_id = "ocid1.compartment.oc1..aaaaaaaanetwork"
  }

  expect_failures = [oci_identity_policy.node_policy]
}

run "rejects_ad_specific_worker_subnet" {
  command = plan

  override_data {
    target = data.oci_core_subnets.network_subnets
    values = {
      subnets = [
        { availability_domain = "", cidr_block = "10.0.0.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaacontrolplane", id = "ocid1.subnet.oc1.iad.aaaaaaaacontrolplane", prohibit_public_ip_on_vnic = true, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = true, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
        { availability_domain = "Uocm:US-ASHBURN-AD-2", cidr_block = "10.0.1.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaaworkers", id = "ocid1.subnet.oc1.iad.aaaaaaaaworkers", prohibit_public_ip_on_vnic = true, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = true, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
      ]
    }
  }

  expect_failures = [oci_core_network_security_group.control_plane_nsg]
}

run "rejects_compartment_wide_identity" {
  command = plan

  variables {
    node_identity = {}
  }

  expect_failures = [oci_identity_dynamic_group.node_dynamic_group]
}

run "rejects_rke2_supervisor_port_collision" {
  command = plan

  variables {
    distribution = "rke2"
    cluster_network = {
      pods            = []
      services        = []
      service_domain  = null
      api_server_port = 9345
    }
  }

  expect_failures = [oci_core_network_security_group.control_plane_nsg]
}

run "invalid_distribution" {
  command = plan

  variables {
    distribution = "k3s"
  }

  expect_failures = [var.distribution]
}

run "rejects_missing_subnet" {
  command = plan

  override_data {
    target = data.oci_core_subnets.network_subnets
    values = {
      subnets = [
        { availability_domain = "", cidr_block = "10.0.0.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaacontrolplane", id = "ocid1.subnet.oc1.iad.aaaaaaaacontrolplane", prohibit_public_ip_on_vnic = true, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = true, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
      ]
    }
  }

  expect_failures = [oci_core_network_security_group.control_plane_nsg]
}

run "rejects_missing_vcn" {
  command = plan

  override_data {
    target = data.oci_core_vcns.network_vcns
    values = {
      virtual_networks = []
    }
  }

  expect_failures = [oci_core_network_security_group.control_plane_nsg]
}

run "invalid_network_compartment_id" {
  command = plan

  variables {
    network_compartment_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn"
  }

  expect_failures = [var.network_compartment_id]
}
