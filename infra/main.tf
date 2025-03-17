
#PROJECT
data "google_project" "project" {
  project_id = var.project
}

#SA
resource "google_service_account" "sa" {
  project      = var.project
  account_id   = "gke-airflow"
  display_name = "Service Account"
}

#GKE
resource "google_container_cluster" "cluster" {
  project                  = var.project
  name                     = "gke-airflow3"
  location                 = var.location
  remove_default_node_pool = true
  deletion_protection      = false
  initial_node_count       = 1
  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }
  monitoring_config {
    managed_prometheus {
      enabled = true
    }
  }
}

resource "google_container_node_pool" "nodepool" {
  project    = var.project
  name       = "gke-airflow3-nodepool"
  location   = var.location
  cluster    = google_container_cluster.cluster.name

  node_config {
    preemptible     = true
    machine_type    = "e2-standard-4"
    service_account = google_service_account.sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }
}
