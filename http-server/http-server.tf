# main.tf
provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "aks-demo" {
  metadata {
    name = "aks-demo"
  }
}

resource "kubernetes_deployment" "http_server" {
  metadata {
    name      = "http-server"
    namespace = "aks-demo"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "http-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "http-server"
        }
      }

      spec {
        container {
          name  = "http-server"
          image = "myacr191768.azurecr.io/demo/ecr:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "http_server" {
  metadata {
    name      = "http-server"
    namespace = "aks-demo"
  }

  spec {
    type = "LoadBalancer"

    port {
      port        = 80
      target_port = 80
    }

    selector = {
      app = kubernetes_deployment.http_server.metadata[0].name
    }
  }
}