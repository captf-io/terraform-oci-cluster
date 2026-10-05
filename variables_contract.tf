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

# Contract inputs of the cluster role, in contract order and with the
# contract's types: https://captf.io/docs/module-author/contract/v1alpha1/common.html
# and https://captf.io/docs/module-author/contract/v1alpha1/cluster.html.

# Read only by its own validation, which is the point of it.
# tflint-ignore: terraform_unused_declarations
variable "captf_contract" {
  description = "Contract version the controller generated the root module for. Always \"v1alpha1\"."
  type        = string

  validation {
    condition     = var.captf_contract == "v1alpha1"
    error_message = "captf_contract must be \"v1alpha1\": this module implements contract v1alpha1 only."
  }
}

variable "captf_cluster" {
  description = "The owning CAPI Cluster: name and namespace. Every cloud resource name derives from it."
  type = object({
    name      = string
    namespace = string
  })
}

# Names derive from the Cluster (captf_cluster); the TerraformCluster, one per
# Cluster, adds nothing to them.
# tflint-ignore: terraform_unused_declarations
variable "captf_object" {
  description = "The TerraformCluster being reconciled: kind, name and namespace."
  type = object({
    kind      = string
    name      = string
    namespace = string
  })
}

# The cluster role never receives captf_cluster_outputs; the contract allows
# declaring it with a null default so all three roles share one skeleton.
# tflint-ignore: terraform_unused_declarations
variable "captf_cluster_outputs" {
  description = "Not passed to the cluster role (common.md \"captf_cluster_outputs\"); declared with a null default and never read."
  type        = any
  default     = null
}

variable "captf_tags" {
  description = "Fixed tags the controller sets (captf.io/cluster, namespace, kind, name, managed-by, template). Applied to every taggable resource as OCI free-form tags."
  type        = map(string)
}

variable "control_plane_endpoint" {
  description = "An endpoint the module does not own (user or control-plane provider). Non-null means: create no API load balancer and report this endpoint."
  type = object({
    host = string
    port = number
  })
  default = null
}

# Version-dependent cluster resources do not exist on OCI with a
# self-managed control plane: the nodes carry the version.
# tflint-ignore: terraform_unused_declarations
variable "kubernetes_version" {
  description = "Cluster.spec.topology.version, or null without ClusterClass. Not used: nothing this module creates depends on the version."
  type        = string
  default     = null
}

# Nothing here needs a live workload API server.
# tflint-ignore: terraform_unused_declarations
variable "control_plane_initialized" {
  description = "Cluster.status.initialization.controlPlaneInitialized, latched. Not used: nothing this module creates waits for the control plane."
  type        = bool
}

variable "cluster_network" {
  description = "Cluster.spec.clusterNetwork. api_server_port sets the API listener and backend port (default 6443)."
  type = object({
    pods            = list(string)
    services        = list(string)
    service_domain  = string
    api_server_port = number
  })
  default = null
}
