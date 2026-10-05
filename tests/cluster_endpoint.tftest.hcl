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

# The API endpoint: its shapes, and the guard that pins it once the load
# balancer exists (CONVENTIONS.md section 12). The first apply creates a
# public load balancer; every rejects_<input>_change run then plans a change
# to one recorded input. Mocks and variables are those of cluster.tftest.hcl.

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

# A plan before any load balancer exists: nothing is recorded yet.
run "rke2_backend_port_is_6443" {
  command = plan

  variables {
    distribution = "rke2"
    cluster_network = {
      pods            = []
      services        = []
      service_domain  = null
      api_server_port = 8443
    }
  }

  assert {
    condition     = oci_network_load_balancer_listener.api_listeners["kube_apiserver"].port == 8443 && oci_network_load_balancer_backend_set.api_backend_sets["kube_apiserver"].health_checker[0].port == 6443
    error_message = "With RKE2 the endpoint keeps api_server_port but the kube-apiserver backends are on 6443, where RKE2 always listens."
  }
  assert {
    condition     = contains(keys(oci_core_network_security_group_security_rule.control_plane_nsg_rules), "ingress-tcp-6443-api-load-balancer") && contains(keys(oci_core_network_security_group_security_rule.api_load_balancer_nsg_rules), "ingress-tcp-8443-10.0.0.0/16")
    error_message = "The load balancer admits the endpoint port and forwards to the backend port."
  }
}

run "public_load_balancer" {
  variables {
    api_load_balancer_public = true
    api_allowed_cidrs        = ["203.0.113.0/24"]
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
  override_resource {
    target = oci_network_load_balancer_network_load_balancer.api_load_balancer
    values = {
      ip_addresses = [
        { ip_address = "10.0.0.10", ip_version = "IPV4", is_public = false, reserved_ip = [] },
        { ip_address = "198.51.100.7", ip_version = "IPV4", is_public = true, reserved_ip = [] },
      ]
      state = "ACTIVE"
    }
  }

  assert {
    condition     = output.control_plane_endpoint == { host = "198.51.100.7", port = 6443 }
    error_message = "A public load balancer's endpoint is its public address."
  }
  assert {
    condition     = !oci_network_load_balancer_network_load_balancer.api_load_balancer[0].is_private
    error_message = "api_load_balancer_public must make the load balancer public."
  }
  assert {
    condition     = contains(keys(oci_core_network_security_group_security_rule.api_load_balancer_nsg_rules), "ingress-tcp-6443-203.0.113.0/24")
    error_message = "api_allowed_cidrs must reach the API port."
  }
  assert {
    condition     = terraform_data.api_endpoint_guard[0].input.address == "198.51.100.7" && terraform_data.api_endpoint_guard[0].input.api_load_balancer_public == true && terraform_data.api_endpoint_guard[0].input.api_server_port == 6443
    error_message = "The endpoint guard must record the inputs and the address of the new load balancer."
  }
}

run "rejects_api_load_balancer_public_change" {
  command = plan

  variables {
    api_load_balancer_public = false
    api_allowed_cidrs        = ["203.0.113.0/24"]
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

  expect_failures = [terraform_data.api_endpoint_guard]
}

run "rejects_api_load_balancer_subnet_id_change" {
  command = plan

  variables {
    api_load_balancer_public    = true
    api_allowed_cidrs           = ["203.0.113.0/24"]
    api_load_balancer_subnet_id = "ocid1.subnet.oc1.iad.aaaaaaaapublic2"
  }

  override_data {
    target = data.oci_core_subnets.network_subnets
    values = {
      subnets = [
        { availability_domain = "", cidr_block = "10.0.0.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaacontrolplane", id = "ocid1.subnet.oc1.iad.aaaaaaaacontrolplane", prohibit_public_ip_on_vnic = false, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = false, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
        { availability_domain = "", cidr_block = "10.0.1.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaaworkers", id = "ocid1.subnet.oc1.iad.aaaaaaaaworkers", prohibit_public_ip_on_vnic = true, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = true, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
        { availability_domain = "", cidr_block = "10.0.2.0/24", compartment_id = "ocid1.compartment.oc1..aaaaaaaacluster", display_name = "aaaaaaaapublic2", id = "ocid1.subnet.oc1.iad.aaaaaaaapublic2", prohibit_public_ip_on_vnic = false, state = "AVAILABLE", vcn_id = "ocid1.vcn.oc1.iad.aaaaaaaavcn", defined_tags = {}, dhcp_options_id = "ocid1.dhcpoptions.oc1.iad.aaaaaaaadhcp", dns_label = "", freeform_tags = {}, ipv4cidr_blocks = [], ipv6cidr_block = "", ipv6cidr_blocks = [], ipv6virtual_router_ip = "", prohibit_internet_ingress = false, route_table_id = "ocid1.routetable.oc1.iad.aaaaaaaaroutes", security_list_ids = [], subnet_domain_name = "", time_created = "2026-01-01 00:00:00 +0000 UTC", virtual_router_ip = "10.0.0.1", virtual_router_mac = "00:00:17:00:00:01" },
      ]
    }
  }

  expect_failures = [terraform_data.api_endpoint_guard]
}

run "rejects_api_load_balancer_private_ip_change" {
  command = plan

  variables {
    api_load_balancer_public     = true
    api_allowed_cidrs            = ["203.0.113.0/24"]
    api_load_balancer_private_ip = "10.0.0.20"
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

  expect_failures = [terraform_data.api_endpoint_guard]
}

run "rejects_api_load_balancer_reserved_public_ip_id_change" {
  command = plan

  variables {
    api_load_balancer_public                = true
    api_allowed_cidrs                       = ["203.0.113.0/24"]
    api_load_balancer_reserved_public_ip_id = "ocid1.publicip.oc1.iad.aaaaaaaareserved"
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

  expect_failures = [terraform_data.api_endpoint_guard]
}

run "rejects_api_server_port_change" {
  command = plan

  variables {
    api_load_balancer_public = true
    api_allowed_cidrs        = ["203.0.113.0/24"]
    cluster_network = {
      pods            = []
      services        = []
      service_domain  = null
      api_server_port = 8443
    }
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

  expect_failures = [terraform_data.api_endpoint_guard]
}
