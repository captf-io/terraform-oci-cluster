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

# User variables of the cluster role, alphabetical. Set them through
# TerraformCluster spec.variables or spec.variablesFrom:
# https://captf.io/docs/user-guide/variables.html. The network is brought by
# the operator (README "Prerequisites"); everything else has a secure default.

variable "additional_tags" {
  description = "Extra OCI free-form tags for every taggable resource. At most 4: OCI allows 10 free-form tags per resource and captf_tags takes 6."
  type        = map(string)
  default     = {}
  nullable    = false

  validation {
    condition     = length(var.additional_tags) <= 4
    error_message = "additional_tags holds at most 4 entries: OCI allows 10 free-form tags per resource and the 6 captf tags are always set."
  }
  validation {
    condition     = alltrue([for k, v in var.additional_tags : can(regex("^[!-~]{1,100}$", k)) && !strcontains(k, ".") && length(v) <= 256])
    error_message = "additional_tags keys must be 1-100 printable ASCII characters without periods or spaces, and values at most 256 characters (OCI tag limits)."
  }
  validation {
    condition     = alltrue([for k in keys(var.additional_tags) : !startswith(lower(k), "captf_io/")])
    error_message = "additional_tags keys must not start with captf_io/: that prefix holds the captf tags, and OCI tag keys are case-insensitive."
  }
}

variable "api_allowed_cidrs" {
  description = "CIDRs allowed to reach the API endpoint, in addition to the VCN's own CIDRs. Required (non-empty) with a public API load balancer; add the management cluster's egress CIDR when it is outside the VCN."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for c in var.api_allowed_cidrs : can(cidrnetmask(c))])
    error_message = "api_allowed_cidrs must hold IPv4 CIDRs such as 203.0.113.0/24."
  }
}

variable "api_load_balancer_private_ip" {
  description = "Private IPv4 address for the API network load balancer, from its subnet. Null lets OCI pick one. Pin it when the endpoint must survive a load balancer replacement."
  type        = string
  default     = null

  validation {
    condition     = var.api_load_balancer_private_ip == null || can(cidrnetmask("${coalesce(var.api_load_balancer_private_ip, "-")}/32"))
    error_message = "api_load_balancer_private_ip must be an IPv4 address such as 10.0.0.10."
  }
}

variable "api_load_balancer_public" {
  description = "Give the API network load balancer a public IP. Off by default: the endpoint stays inside the VCN. Turning it on requires api_allowed_cidrs."
  type        = bool
  default     = false
  nullable    = false
}

variable "api_load_balancer_reserved_public_ip_id" {
  description = "OCID of a reserved public IP for a public API network load balancer. Null lets OCI assign an ephemeral one. Pin it when the endpoint must survive a load balancer replacement."
  type        = string
  default     = null

  validation {
    condition     = var.api_load_balancer_reserved_public_ip_id == null || startswith(coalesce(var.api_load_balancer_reserved_public_ip_id, "-"), "ocid1.publicip.")
    error_message = "api_load_balancer_reserved_public_ip_id must be a public IP OCID (ocid1.publicip.…)."
  }
}

variable "api_load_balancer_subnet_id" {
  description = "OCID of the subnet for the API network load balancer. Null uses control_plane_subnet_id. A public load balancer needs a public subnet."
  type        = string
  default     = null

  validation {
    condition     = var.api_load_balancer_subnet_id == null || startswith(coalesce(var.api_load_balancer_subnet_id, "-"), "ocid1.subnet.")
    error_message = "api_load_balancer_subnet_id must be a subnet OCID (ocid1.subnet.…)."
  }
}

variable "compartment_id" {
  description = "OCID of the compartment for every resource of the cluster (machines and pools included). Required: the module cannot guess it."
  type        = string
  default     = null

  validation {
    condition     = var.compartment_id != null && can(regex("^ocid1\\.(compartment|tenancy)\\.", coalesce(var.compartment_id, "-")))
    error_message = "compartment_id is required: set spec.variables.compartment_id on the TerraformCluster to a compartment OCID (ocid1.compartment.…)."
  }
}

variable "control_plane_subnet_id" {
  description = "OCID of the existing subnet for control-plane nodes. Required: the network is brought by the operator. Its VCN is the cluster's VCN."
  type        = string
  default     = null

  validation {
    condition     = var.control_plane_subnet_id != null && startswith(coalesce(var.control_plane_subnet_id, "-"), "ocid1.subnet.")
    error_message = "control_plane_subnet_id is required: set spec.variables.control_plane_subnet_id on the TerraformCluster to a subnet OCID (ocid1.subnet.…)."
  }
}

variable "distribution" {
  description = "The Kubernetes distribution: kubeadm, or rke2 (RKE2ControlPlane), which adds the supervisor listener on 9345 and puts the kube-apiserver backends on 6443. kubeadm by default."
  type        = string
  default     = "kubeadm"
  nullable    = false

  validation {
    condition     = contains(["kubeadm", "rke2"], var.distribution)
    error_message = "distribution must be kubeadm or rke2."
  }
}

variable "failure_domain_mode" {
  description = "What a CAPI failure domain is: availability_domain, fault_domain (the fault domains of one availability domain), or auto (availability domains where the region has several, else fault domains, as CAPOCI does)."
  type        = string
  default     = "auto"
  nullable    = false

  validation {
    condition     = contains(["auto", "availability_domain", "fault_domain"], var.failure_domain_mode)
    error_message = "failure_domain_mode must be auto, availability_domain or fault_domain."
  }
}

variable "home_region" {
  description = "The tenancy's home region, where IAM writes go. Null looks it up from the tenancy's region subscriptions; set it when the identity may not list them."
  type        = string
  default     = null

  validation {
    condition     = var.home_region == null || can(regex("^[a-z]+(-[a-z]+)+-[0-9]+$", coalesce(var.home_region, "-")))
    error_message = "home_region must be an OCI region identifier such as us-ashburn-1."
  }
}

variable "ignore_defined_tags" {
  description = "Defined tags (\"<namespace>.<key>\") that tenancy tag defaults add and Terraform should not manage, on top of Oracle-Tags.CreatedBy and Oracle-Tags.CreatedOn, which are always ignored."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = length(var.ignore_defined_tags) <= 98 && alltrue([for t in var.ignore_defined_tags : can(regex("^[^. ]+\\.[^. ]+$", t))])
    error_message = "ignore_defined_tags holds at most 98 entries of the form <namespace>.<key> (the provider allows 100; two are Oracle-Tags)."
  }
}

variable "network_compartment_id" {
  description = "OCID of the compartment of the VCN and its subnets. Null uses compartment_id. The module lists the subnets and VCNs there rather than reading each, so a destroy still finishes once the network is gone."
  type        = string
  default     = null

  validation {
    condition     = var.network_compartment_id == null || can(regex("^ocid1\\.(compartment|tenancy)\\.", coalesce(var.network_compartment_id, "-")))
    error_message = "network_compartment_id must be a compartment or tenancy OCID."
  }
}

variable "node_identity" {
  description = "Instance-principal identity for the control-plane nodes, where the OCI cloud controller manager and CSI controller run. enabled creates a dynamic group and a policy. defined_tag (an existing tag namespace and key) scopes the group to this cluster's control-plane instances, which carry the tag; without one the group would be every instance in the compartment, which needs allow_compartment_wide."
  type = object({
    enabled = optional(bool, true)
    defined_tag = optional(object({
      namespace = string
      key       = string
    }))
    allow_compartment_wide = optional(bool, false)
  })
  default  = {}
  nullable = false

  validation {
    condition = var.node_identity.defined_tag == null || alltrue([
      for s in [try(var.node_identity.defined_tag.namespace, ""), try(var.node_identity.defined_tag.key, "")] : can(regex("^[!-~]{1,100}$", s)) && !strcontains(s, ".")
    ])
    error_message = "node_identity.defined_tag namespace and key must be existing OCI tag names: 1-100 printable ASCII characters without periods or spaces."
  }
}

variable "node_policy_compartment_id" {
  description = "OCID of the compartment the node policy is attached to. Null uses compartment_id. Set it to a common ancestor (the tenancy) when the VCN lives in another compartment: a policy only governs its own compartment and those below it."
  type        = string
  default     = null

  validation {
    condition     = var.node_policy_compartment_id == null || can(regex("^ocid1\\.(compartment|tenancy)\\.", coalesce(var.node_policy_compartment_id, "-")))
    error_message = "node_policy_compartment_id must be a compartment or tenancy OCID."
  }
}

variable "nodeport_allowed_cidrs" {
  description = "CIDRs allowed to reach worker NodePorts (30000-32767, TCP and UDP). Empty by default: add the subnets of the load balancers the cloud controller manager creates for Services."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for c in var.nodeport_allowed_cidrs : can(cidrnetmask(c))])
    error_message = "nodeport_allowed_cidrs must hold IPv4 CIDRs such as 10.0.10.0/24."
  }
}

variable "region" {
  description = "OCI region identifier of the cluster, such as us-ashburn-1. Required: it is a property of the cluster, not of the credentials. Machines and pools inherit it."
  type        = string
  default     = null

  validation {
    condition     = var.region != null && can(regex("^[a-z]+(-[a-z]+)+-[0-9]+$", coalesce(var.region, "-")))
    error_message = "region is required: set spec.variables.region on the TerraformCluster to an OCI region identifier such as us-ashburn-1."
  }
}


variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed to reach the nodes on SSH (TCP 22). Empty by default: no SSH."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for c in var.ssh_allowed_cidrs : can(cidrnetmask(c))])
    error_message = "ssh_allowed_cidrs must hold IPv4 CIDRs such as 10.0.0.0/16."
  }
}

variable "tenancy_id" {
  description = "OCID of the tenancy, where the node dynamic group lives. Null reads the identity's OCI_TENANCY_OCID file under /var/run/captf/credentials. Only needed when node_identity.enabled."
  type        = string
  default     = null

  validation {
    condition     = var.tenancy_id == null || startswith(coalesce(var.tenancy_id, "-"), "ocid1.tenancy.")
    error_message = "tenancy_id must be a tenancy OCID (ocid1.tenancy.…)."
  }
}

variable "worker_subnet_id" {
  description = "OCID of the existing subnet for worker nodes. Null uses control_plane_subnet_id. Must be in the same VCN."
  type        = string
  default     = null

  validation {
    condition     = var.worker_subnet_id == null || startswith(coalesce(var.worker_subnet_id, "-"), "ocid1.subnet.")
    error_message = "worker_subnet_id must be a subnet OCID (ocid1.subnet.…)."
  }
}
