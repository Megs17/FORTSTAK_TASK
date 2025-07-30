# Todo List Application

## Overview
This project is a web-based Todo List application that allows users to create, manage, and delete tasks through a user-friendly interface. The application is built with Node.js, Express.js, EJS, CSS, JavaScript, MongoDB, and Mongoose, and uses Nodemon for development. It is containerized using Docker, provisioned with Terraform, configured with Ansible, and deployed on Kubernetes with Argo CD for continuous deployment. The infrastructure is hosted on AWS, with a MongoDB instance running in the Kubernetes cluster. Docker Compose is provided for local development, and a GitHub Actions workflow automates building and pushing the Docker image to AWS ECR.

## Directory Structure
Below is the structure of the project directories and their purposes:

- **`.github/workflows`**: Contains GitHub Actions workflows for CI/CD automation.
  - *Files*:
    - `Build and Push Todo-List-nodejs to ECR`: A workflow that triggers on pushes to the `main` branch, builds the Todo List Docker image, pushes it to AWS ECR, updates the `todo-deployment.yml` manifest with the new image tag, and commits the change back to the repository.
   

- **`app-docker-compose`**: Contains the Docker Compose configuration for running the Todo List application and MongoDB locally for development and testing.
  - *Files*:
    - `docker-compose.yml`: Defines two services:
      - `app`: Runs the Todo List application using the `todo-list-nodejs` image, mapping port `4000:4000`, and connecting to MongoDB via `MONGODB_URI`

- **`infra_terraform_code`**: Holds Terraform scripts for provisioning AWS infrastructure, including a VPC, subnets, security groups, internet gateway, route tables, key pairs, and EC2 instances for a Kubernetes cluster.
  - *Files*:
    - `variables.tf`: Defines input variables for AWS region (`region`), environment (`env`), availability zones (`zone1`), key pair name (`key_name`), and number of worker nodes (`worker_nodes_count`).
    - `subnets.tf`: Creates a public subnet in Availability Zone `us-east-1a` with CIDR block `10.0.64.0/19` and auto-assigns public IPs to instances.
    - `provider.tf`: Configures the AWS provider (version ~> 5.95), Terraform version (>= 1.5), and required providers (AWS, TLS, Ansible).
    - `routes.tf`: Sets up a public route table with a route to the internet gateway for public subnet traffic.
    - `security_groups.tf`: Defines security groups for:
      - `Common-SG`: Allows HTTP (80), HTTPS (443), SSH (22), Calico BGP (179), and NodePort services (30000-32767).
      - `control_plane_sg`: Allows Kubernetes API (6443), Etcd (2379-2380), Kubelet (10250), Scheduler (10259), and Controller Manager (10257).
      - `worker_nodes_sg`: Allows Kubelet API (10250, 10256) and NodePort services (30000-32767).
      - `flannel_networking_sg`: Allows Flannel UDP ports (8285, 8472).
    - `vpc.tf`: Provisions a VPC with CIDR block `10.0.0.0/16`, enabling DNS support and hostnames.
    - `keys.tf`: Generates an RSA key pair for SSH access and registers it with AWS as `my-key-pair-us-east-1`.
    - `igw.tf`: Creates an internet gateway attached to the VPC for internet access.
    - `instances.tf`: Provisions EC2 instances:
      - One `t2.medium` instance for the Kubernetes control plane.
      - `worker_nodes` `t2.small` instances for worker nodes.
      - Instances include associated security groups, IAM instance profiles, and public IPs.
  
   - `inventory.yaml`: Configures the Ansible inventory using the `cloud.terraform` plugin, sourcing instance details from the Terraform state file.
    - `playbook.yaml`: Defines Ansible tasks to:
      - Configure all nodes with prerequisites (disable swap, install dependencies, containerd, Kubernetes tools).
      - Initialize the Kubernetes control plane with `kubeadm init` and apply Flannel CNI.
      - Join worker nodes to the cluster using the `kubeadm join` command.
      - Set up AWS ECR credentials and Argo CD for continuous deployment.
      - `ansible.cfg`: Configures Ansible to disable SSH host key checking for simplified connections to EC2 instances.
  - `requirements.yaml`: Specifies the `cloud.terraform` Ansible collection (>= 4.0.0) for Terraform-Ansible integration.

- **`manifests`**: Contains Kubernetes manifest files for deploying the Todo List application and MongoDB on the Kubernetes cluster, along with an Argo CD application for continuous deployment.
  - *Files*:
    - `argocd-app.yml`: Defines an Argo CD `Application` resource to manage the Todo List application deployment from a Git repository (`https://github.com/ramy-22/ToDo-List-K8S`), targeting the `default` namespace with automated sync and pruning.
    - `mongo-deployment.yml`: Deploys a single MongoDB pod using the `mongo:5.0` image, with a container port of 27017 
    - `mongo-service.yml`: Exposes the MongoDB deployment as a Headles ClusterIP service on port 27017.
    - `node-deployment.yml`: Deploys two replicas of the Todo List application using the image `257034520231.dkr.ecr.us-east-1.amazonaws.com/todolist:latest`.
    - `node-service.yml`: Exposes the Todo List deployment as a NodePort service on port 4000, mapping to node port 30080 for external access.

- **`Todo-List-nodejs`**: Contains the source code for the Node.js-based Todo List application, including the Dockerfile for containerization.
  - *Files*:
    - `Dockerfile`: Defines the Docker image for the Node.js application, using `node:18-alpine` as the base image, installing production dependencies, and running the application on port 4000.

## Technologies Used
- **Node.js**: Backend runtime environment.
- **Express.js**: Framework for creating API routes.
- **EJS**: Templating engine for rendering dynamic views.
- **CSS**: Styling for the web interface.
- **JavaScript**: Client-side and server-side logic.
- **MongoDB**: Database for storing tasks.
- **Mongoose**: ODM for MongoDB to manage database operations.
- **Nodemon**: Development tool for auto-restarting the server.
- **Docker**: Containerization for consistent deployment.
- **Docker Compose**: Local multi-container orchestration.
- **Ansible**: Configuration management for Kubernetes cluster setup.
- **Terraform**: Infrastructure provisioning (AWS VPC, EC2, security groups).
- **Kubernetes**: Orchestration for containerized deployment.
- **AWS**: Cloud provider for infrastructure (VPC, EC2, ECR).
- **Argo CD**: Continuous deployment for Kubernetes applications.
- **Flannel**: Networking CNI for Kubernetes pod communication.
- **GitHub Actions**: CI/CD pipeline for building and deploying the Docker image.

## Prerequisites
- **Node.js** (v18 or higher)
- **Docker** (for building and running containers)
- **Docker Compose** (v2.0 or higher, for local multi-container setup)
- **Terraform** (v1.5 or higher, with AWS provider ~> 5.95)
- **Ansible** (with `cloud.terraform` collection >= 4.0.0)
- **Kubernetes** (kubectl for interacting with the cluster)
- **AWS CLI** (configured with credentials and permissions for EC2, ECR, and IAM)
- **Python** (for Ansible)
- **SSH** client (for debugging, if needed)
- **Git** (for Argo CD and GitHub Actions)
- **GitHub Repository**: Access to `https://github.com/ramy-22/ToDo-List-K8S` with write permissions for GitHub Actions.

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/ramy-22/ToDo-List-K8S.git
cd FORTSTAK_TASK

```

### 2. Configure GitHub Actions Secrets
1. In your GitHub repository (`https://github.com/ramy-22/ToDo-List-K8S`), navigate to **Settings > Secrets and variables > Actions > Secrets**.
2. Add the following repository secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS Access Key ID with permissions for ECR and EC2.
   - `AWS_SECRET_ACCESS_KEY`: Your AWS Secret Access Key.
   - `AWS_REGION`: The AWS region (e.g., `us-east-1`).
   - `ECR_REPOSITORY`: The ECR repository name (e.g., `todolist`).

### 3. Local Development with Node.js
1. Navigate to the `Todo-List-nodejs` directory:
   ```bash
   cd Todo-List-nodejs
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Set up environment variables in a `.env` file:
   ```bash
   echo "MONGODB_URI=mongodb://admin:your-secure-password@localhost:27017/todolist?authSource=admin" > .env
   ```
4. Run the application locally (for development):
   ```bash
   npm run dev
   ```
   This uses Nodemon to start the server on `http://localhost:4000`.

### 4. Local Development with Docker Compose
1. Navigate to the `app-docker-compose` directory:
   ```bash
   cd app-docker-compose
   ```
2. Build and run the services:
   ```bash
   docker-compose up --build
   ```
   - The `app` service runs the Todo List application on `http://localhost:4000`.
   - The `mongo` service runs MongoDB on `mongodb://localhost:27017`
3. Access the application at `http://localhost:4000`.

### 5. Build and Push Docker Image to AWS ECR
1. Build the Docker image from the `Todo-List-nodejs` directory:
   ```bash
   cd Todo-List-nodejs
   docker build -t todo-list-nodejs .
   ```
2. Tag and push the image to AWS ECR (manual alternative to GitHub Actions):
   ```bash
 aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<your-region>.amazonaws.com

 docker tag <local-image-name>:latest <aws_account_id>.dkr.ecr.<your-region>.amazonaws.com/<repository-name>:latest

 docker push <aws_account_id>.dkr.ecr.<your-region>.amazonaws.com/<repository-name>:latest

   ```

### 6. Infrastructure Provisioning
1. Configure AWS credentials:
   - Ensure the AWS CLI is installed and configured with appropriate IAM permissions (EC2, ECR, IAM):
     ```bash
     aws configure
     ```
   - Provide your AWS Access Key ID, Secret Access Key, region (e.g., `us-east-1`), and output format.

2. Navigate to the `infra_terraform_code` directory:
   ```bash
   cd infra_terraform_code
   ```

3. Initialize Terraform to download providers and modules:
   ```bash
   terraform init
   ```

4. (Optional) Customize variables in `variables.tf`:
   - `region`: Default is `us-east-1`. Change to another AWS region if needed.
   - `env`: Default is `dev`. Set to `prod` or `staging` for different environments.
   - `zone1`, `zone2`: Availability zones (default: `us-east-1a`, `us-east-1b`).
   - `key_name`: Name for the SSH key pair (default: `my-key-pair-us-east-1`).
   - `worker_nodes_count`: Number of Kubernetes worker nodes (default: 1).


5. Preview the infrastructure changes:
   ```bash
   terraform plan
   ```

6. Apply the Terraform configuration to provision the AWS infrastructure:
   ```bash
   terraform apply
   ```
   - Confirm with `yes` when prompted.
   - This creates:
     - A VPC (`10.0.0.0/16`) with DNS support and hostnames enabled.
     - A public subnet in `us-east-1a` (`10.0.64.0/19`) with public IP assignment.
     - An internet gateway and route table for public access.
     - Security groups for Kubernetes control plane, worker nodes, Flannel networking, and common services (ports 80, 443, 22, 6443, 30000-32767, etc.).
     - An RSA key pair (`my-key-pair-us-east-1`) for SSH access, stored in `private_key.pem` and `public_key.pem`.
     - An IAM role for EC2 instances with ECR pull access, allowing nodes to authenticate and pull images from Amazon ECR
     - EC2 instances: one `t2.medium` for the control plane and `worker_nodes_count` `t2.small` worker nodes.
     - A hosts file (`files/hosts`) with instance IPs for Ansible.

7. Secure the private key:
   ```bash
   chmod 400 private_key.pem
   ```

### 7. Server Configuration

1. Install the required Ansible collections:
   ```bash
   ansible-galaxy collection install -r requirements.yaml
   ```

2. Run the Ansible playbook to configure the Kubernetes cluster:
   ```bash
   ansible-playbook -i inventory.yaml playbook.yaml
   ```
   - The `inventory.yaml` file uses the `cloud.terraform` plugin to dynamically fetch EC2 instance details from `terraform.tfstate`.
   - The `playbook.yaml` performs the following:
     - **Basic Setup (all nodes)**:
       - Waits for SSH connectivity (port 22).
       - Disables swap and configures kernel modules (`overlay`, `br_netfilter`) for Kubernetes.
       - Installs dependencies (unzip, curl, containerd, AWS CLI).
       - Configures containerd with the systemd cgroup driver.
       - Installs Kubernetes tools (kubelet, kubeadm, kubectl) and CNI plugins.
     - **Control Plane Setup**:
       - Initializes the Kubernetes control plane with `kubeadm init` using pod network CIDR `10.244.0.0/16`.
       - Applies Flannel CNI for pod networking.
       - Copies the Kubernetes admin configuration to `/home/ubuntu/.kube/config`.
       - Generates a `kubeadm join` command for worker nodes.
     - **Worker Nodes Setup**:
       - Joins worker nodes to the cluster using the `kubeadm join` command from the control plane.
     - **ECR and Argo CD Setup**:
       - Creates a Kubernetes secret (`ecr-secret`) for AWS ECR authentication using the account ID `257034520231` as EC2 have IAM Role to access ECR.
       - Patches the default service account to use the ECR secret for pulling images.
       - Installs Argo CD in the `argocd` namespace and configures the `argocd-server` service as a NodePort.

4. Retrieve the Kubernetes configuration for local access:
   ```bash
   scp -i infra_terraform_code/private_key.pem ubuntu@<control-plane-public-ip>:/home/ubuntu/.kube/config ~/.kube/config
   ```
   Replace `<control-plane-public-ip>` with the public IP of the control plane instance (found in `infra_terraform_code/files/hosts`).

### 8. Kubernetes Deployment
1. Navigate to the `manifests` directory:
   ```bash
   cd manifests
   ```

2. Apply the Kubernetes manifests to deploy MongoDB and the Todo List application:
   ```bash
   kubectl apply -f mongo-deployment.yml
   kubectl apply -f mongo-service.yml
   kubectl apply -f node-deployment.yml
   kubectl apply -f node-service.yml
   kubectl apply -f argocd-app.yml
   ```
   - `mongo-deployment.yml`: Deploys one MongoDB pod (`mongo:5.0`) with port 27017.
   - `mongo-service.yml`: Exposes MongoDB as a ClusterIP service (`mongodb-service`) on port 27017.
   - `node-deployment.yml`: Deploys three replicas of the Todo List application using `257034520231.dkr.ecr.us-east-1.amazonaws.com/todolist:<commit-sha>` (updated by GitHub Actions).
   - `node-service.yml`: Exposes the application as a NodePort service on port 4000, accessible at node port 30007.
   - `argocd-app.yml`: Defines an ArgoCD Application resource that continuously syncs the Kubernetes manifests from the GitHub repository to the cluster, automating deployment of the Todo List application.

3. Apply the Argo CD application manifest to manage deployments:
   ```bash
   kubectl apply -f argocd-app.yml
   ```
   - The `argocd-app.yml` configures Argo CD to sync the Todo List application from `https://github.com/ramy-22/ToDo-List-K8S` to the `default` namespace with automated sync and pruning.

### 9. Access Argo CD
1. Get the Argo CD server NodePort:
   ```bash
   kubectl get svc argocd-server -n argocd
   ```
   Note the NodePort (e.g., 30080) assigned to the `argocd-server` service.

2. Access Argo CD at `http://<worker-node-public-ip>:<argo-cd-node-port>` (e.g., `http://<worker-node-public-ip>:30080`).
   - Use a worker node’s public IP from `infra_terraform_code/files/hosts`.
   - Retrieve the initial admin password:
     ```bash
      
     ```

3. Log in to Argo CD and verify that the Todo List application is synced from `https://github.com/Megs17/FORTSTAK_TASK`.


## CI/CD Pipeline
The `.github/workflows/Build and Push Todo-List-nodejs to ECR` workflow automates the following on pushes to the `main` branch:
1. Checks out the repository code.
2. Sets up Docker Buildx for building the Docker image.
3. Configures AWS credentials using GitHub Actions secrets.
4. Logs in to AWS ECR (`257034520231.dkr.ecr.us-east-1.amazonaws.com`).
5. Builds and pushes the Docker image to ECR with the tag `<commit-sha>`.
6. Updates the `manifests/todo-deployment.yml` file with the new image tag.
7. Commits and pushes the updated manifest to the `main` branch.
8. Argo CD syncs the updated manifests from `https://github.com/ramy-22/ToDo-List-K8S` and deploys the new image.

## Cleanup
   ```
1. Destroy the AWS infrastructure:
   ```bash
   cd infra_terraform_code
   terraform destroy
   ```
## Kubernetes Cluster Setup Resources

The Kubernetes cluster setup using `kubeadm` was guided and inspired by both official documentation and community contributions:

- 📘 **Kubernetes Official Documentation**  
  Comprehensive step-by-step guide for installing and configuring a production-ready Kubernetes cluster using `kubeadm`:  
  👉 [https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

- 📁 **CKA 2024 GitHub Repository by piyushsachdeva**  
  A detailed and practical repository that walks through Kubernetes setup, covering various cluster operations useful for hands-on configuration and CKA exam preparation:  
  👉 [https://github.com/piyushsachdeva/CKA-2024/tree/main/Resources/Day27](https://github.com/piyushsachdeva/CKA-2024/tree/main/Resources/Day27#run-the-below-steps-on-the-master-vm)

These resources were instrumental in building and automating the Kubernetes control plane and worker nodes using `kubeadm`, particularly for network setup, system configuration, and best practices.


## 🌐 Live Demo

You can explore the deployed Todo List application and access the Argo CD dashboard using the following links:

### ✅ Todo List Application  
- **URL**: [http://54.89.223.23:30080](http://54.89.223.23:30080)  
- This is the user-facing web application where you can add, delete, and manage your todos.

### 🚀 Argo CD Dashboard  
- **URL**: [http://54.89.223.23:32212](http://54.89.223.23:32212)  
- **Username**: `admin`  
- **Password**: `SzYNRP6m5-UfGH9O`  
- Use this dashboard to view and manage the GitOps deployments in the Kubernetes cluster.


## 📬 Contact

Feel free to reach out if you have any questions, feedback, or collaboration ideas:

- 📧 **Email**: [ahmedfec2000@gmail.com](mailto:ahmedfec2000@gmail.com)  
- 💻 **GitHub**: [Ahmed Magdy](https://github.com/Megs17)
