terraform {
  required_version = ">= 1.6.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {}

variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig"
  default     = "~/.kube/config"
}

resource "kubernetes_namespace" "n8n" {
  metadata {
    name = "n8n"
  }
}

resource "helm_release" "n8n" {
  name       = "n8n"
  repository = "https://helm.n8n.io"
  chart      = "n8n"
  namespace  = kubernetes_namespace.n8n.metadata[0].name

  values = [file("${path.module}/../kubernetes/values-ha.yaml")]
}
