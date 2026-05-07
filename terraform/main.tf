terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "flask-app"
    labels = {
      environment = "development"
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_resource_quota" "app_quota" {
  metadata {
    name      = "flask-app-quota"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    hard = {
      "requests.cpu"    = "500m"
      "requests.memory" = "256Mi"
      "limits.cpu"      = "1"
      "limits.memory"   = "512Mi"
    }
  }
}