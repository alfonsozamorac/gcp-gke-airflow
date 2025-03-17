#  **Deploy Apache Airflow on GKE with Terraform & Helm**
This project provides an automated way to deploy **Apache Airflow** on **Google Kubernetes Engine (GKE)** using **Terraform** for infrastructure provisioning and **Helm** for Airflow deployment.

## **Features**
- Deploys a **GKE cluster** with a configurable node pool.  
- Uses **Helm** to install and manage Airflow.  
- Supports **public access** via LoadBalancer or Ingress with HTTPS.  
- Synchronizes **DAGs from a Git repository**.  
- **Scalable & Cloud-Native** setup with KubernetesExecutor.  


## **Installation**
1. Replace and export with your correct value:

   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="?"
   export TF_VAR_project="?"
   export TF_VAR_location="?"
   ```

2. Set variables values to Airflow (macOS):
   ```bash
   PASSWORD_USER=$(openssl rand -hex 32)
   PASSWORD_WEB=$(openssl rand -hex 32)
   sed -i '' "s|random_password_user|$PASSWORD_USER|" ./conf/values.yaml
   sed -i '' "s|random_password_web|$PASSWORD_WEB|" ./conf/values.yaml
   ```

3. Create infrastructure:

   ```bash
   terraform -chdir="./infra" init -upgrade
   terraform -chdir="./infra" apply --auto-approve
   ```

4. Get the output variables:

   ```bash
   export GKE_CLUSTER="$(terraform -chdir="./infra" output -raw gke_cluster)"
   ```


5. Configure kubectl:

   ```bash
   gcloud container clusters get-credentials ${GKE_CLUSTER} --region ${TF_VAR_location} --project ${TF_VAR_project}
   ```

6. Deploy Airflow using Helm:

   ```bash
   helm repo add apache-airflow https://airflow.apache.org
   helm repo update
   helm search repo apache-airflow/airflow --versions
   helm install airflow apache-airflow/airflow --version 1.15.0 -f conf/values.yaml --namespace airflow --create-namespace
   ```

7. Airflow credentials:

   ```bash
   echo "user: admin"
   echo "password: ${PASSWORD_USER}"
   ```

8. Open your browser with the external IP to Access Airflow UI:

   ```bash
   kubectl get pods -n airflow
   #If the webserver pod is not running, delete it with:
   #kubectl delete pod airflow-webserver-... -n airflow
   kubectl get svc -n airflow airflow-webserver
   ```

## Clean resources

1. Destroy resources:

   ```bash
   terraform -chdir="./infra" destroy --auto-approve
   ```
