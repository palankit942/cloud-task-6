provider "aws" {
  region  = "ap-south-1"
  profile = "ankit"

}
provider "kubernetes" {
  config_context_cluster   = "minikube"
}

resource "aws_db_instance" "mysql" {
  #db_instance_identifier = "my-database"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.30"
  instance_class       = "db.t2.micro"
  name                 = "wordpress_db"
  username             = "admin"
  password             = "Ankitrp@1"
  parameter_group_name = "default.mysql5.7"
  publicly_accessible = "true"
  port                = "3306"
  vpc_security_group_ids= ["sg-03fa93c5066006bc5",]
  final_snapshot_identifier = "false"
  skip_final_snapshot = "true"
} 

resource "kubernetes_service" "service" {
    depends_on = [kubernetes_deployment.MyDeploy]
  metadata {
    name = "my-service"
  }
    spec {
    selector = {
      App = kubernetes_deployment.MyDeploy.metadata.0.labels.App
    }
    
    port {
      port        = 8080
      target_port = 80
    }

    type = "NodePort"
    }  
}



    
resource "kubernetes_deployment" "MyDeploy" {
    depends_on = [aws_db_instance.mysql]
  metadata {
    name = "wordpress"
    labels = {
      App = "MyApp"
    }
  }

spec {
    replicas = 1

    selector {
      match_labels = {
        App = "MyApp"
      }
    }

    template {
      metadata {
          labels = {
             App = "MyApp"
            }
       }

      spec {
        container {
          image = "wordpress"
          name  = "my-wordpress"
         
         port {
               container_port = 80
            }
          
        }
      
    }
  }
}

}
