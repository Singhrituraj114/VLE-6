# Virtual Lab Experiment 6 - CI/CD Pipeline

🎯 **Objective**: Build and deploy a Dockerized Java web application to a Kubernetes cluster on AWS using a fully automated CI/CD pipeline with Jenkins, Maven, GitHub, Terraform, and Ansible.

## 🛠️ Technologies Used

- **Infrastructure as Code**: Terraform
- **Configuration Management**: Ansible
- **Containerization**: Docker
- **CI/CD**: Jenkins
- **Source Control**: GitHub
- **Build Automation**: Maven
- **Orchestration**: Kubernetes (EKS)
- **Cloud Platform**: AWS
- **Application**: Spring Boot Java Web App

## 📁 Project Structure

```
VLE-6/
├── src/                          # Java Spring Boot application
│   ├── main/java/com/example/
│   │   ├── SampleJavaAppApplication.java
│   │   └── controller/HelloController.java
│   ├── main/resources/
│   │   └── application.properties
│   └── test/java/com/example/controller/
│       └── HelloControllerTest.java
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                   # Main Terraform configuration
│   ├── variables.tf              # Variable definitions
│   ├── outputs.tf                # Output values
│   ├── vpc.tf                    # VPC and networking
│   ├── jenkins.tf                # Jenkins EC2 instance
│   ├── eks.tf                    # EKS cluster configuration
│   ├── jenkins-userdata.sh       # Jenkins installation script
│   └── terraform.tfvars.example  # Example variables file
├── ansible/                      # Configuration Management
│   ├── inventory.ini             # Inventory file
│   ├── ansible.cfg               # Ansible configuration
│   └── install-jenkins.yml       # Jenkins installation playbook
├── k8s/                          # Kubernetes manifests
│   ├── deployment.yaml           # Development deployment
│   ├── production-deployment.yaml # Production deployment
│   └── configmap.yaml            # Configuration maps
├── pom.xml                       # Maven build configuration
├── Dockerfile                    # Container definition
├── Jenkinsfile                   # CI/CD pipeline definition
├── setup.sh                     # Automated setup script
└── README.md                     # This file
```

## 🚀 Quick Start

### Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
3. **Terraform** (>= 1.0)
4. **Ansible** (>= 2.9)
5. **Git**
6. **SSH Key Pair** in AWS for EC2 access

### Automated Setup

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   cd VLE-6
   ```

2. **Run the automated setup**:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Follow the interactive prompts** to deploy infrastructure and configure services.

### Manual Setup

#### Step 1: Infrastructure Deployment (Terraform)

1. **Configure Terraform variables**:
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your AWS settings
   ```

2. **Deploy infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Note the outputs** (Jenkins IP, EKS cluster name, etc.)

#### Step 2: Jenkins Configuration (Ansible)

1. **Update Ansible inventory**:
   ```bash
   cd ../ansible
   # Edit inventory.ini with Jenkins EC2 IP from Terraform output
   ```

2. **Run Ansible playbook**:
   ```bash
   ansible-playbook install-jenkins.yml -i inventory.ini
   ```

#### Step 3: Kubernetes Setup

1. **Configure kubectl**:
   ```bash
   aws eks update-kubeconfig --region us-west-2 --name vle-6-cicd-eks-cluster
   ```

2. **Deploy Kubernetes resources**:
   ```bash
   kubectl apply -f k8s/
   ```

#### Step 4: Jenkins Pipeline Configuration

1. **Access Jenkins** at `http://<jenkins-ip>:8080`
2. **Install required plugins**:
   - GitHub Integration
   - Maven Integration
   - Docker Pipeline
   - Kubernetes CLI
   - Pipeline

3. **Configure credentials**:
   - Docker Hub credentials (ID: `docker-hub-credentials`)
   - AWS credentials for kubectl access
   - GitHub credentials (if private repo)

4. **Create Pipeline Job**:
   - New Item → Pipeline
   - Configure SCM to point to your repository
   - Use `Jenkinsfile` from repository

## 🔧 Configuration Details

### Terraform Configuration

The Terraform configuration creates:
- **VPC** with public and private subnets
- **EKS Cluster** with managed node groups
- **EC2 Instance** for Jenkins server
- **Security Groups** with appropriate rules
- **IAM Roles** for EKS and Jenkins

### Jenkins Pipeline Stages

1. **Checkout Code** - Pull code from GitHub
2. **Build with Maven** - Compile and test Java application
3. **Code Quality Analysis** - Run unit and integration tests
4. **Build Docker Image** - Create container image
5. **Security Scan** - Scan Docker image for vulnerabilities
6. **Push to Registry** - Upload image to Docker Hub
7. **Deploy to Development** - Deploy to dev namespace
8. **Integration Testing** - Test deployed application
9. **Deploy to Production** - Deploy to prod (with approval)

### Application Endpoints

Once deployed, the application exposes:
- `/` - Hello World message
- `/health` - Application health status
- `/version` - Application version and build info
- `/actuator/health` - Spring Boot health endpoint

## 🔄 CI/CD Workflow

1. **Developer pushes code** to GitHub repository
2. **Jenkins detects changes** and triggers pipeline
3. **Code is built** using Maven
4. **Tests are executed** (unit + integration)
5. **Docker image is created** and pushed to registry
6. **Application is deployed** to Kubernetes development environment
7. **Integration tests** are run against deployed app
8. **Manual approval** required for production deployment
9. **Production deployment** with zero-downtime rolling update

## 🛡️ Security Considerations

- **IAM roles** with least privilege access
- **Security groups** restricting network access
- **Private subnets** for EKS worker nodes
- **Image scanning** for vulnerabilities
- **Non-root containers** in Docker images
- **Network policies** in Kubernetes (optional)

## 🔍 Monitoring & Logging

- **Spring Boot Actuator** for application metrics
- **Kubernetes health checks** (liveness/readiness probes)
- **EKS cluster logging** enabled
- **Jenkins build history** and artifacts
- **AWS CloudWatch** integration

## 🚨 Troubleshooting

### Common Issues

1. **Jenkins not accessible**:
   - Check security groups allow port 8080
   - Verify EC2 instance is running
   - Check Jenkins service status: `sudo systemctl status jenkins`

2. **EKS cluster access denied**:
   - Verify AWS credentials and IAM permissions
   - Check kubeconfig: `kubectl config current-context`
   - Ensure EKS cluster is in running state

3. **Docker build fails**:
   - Check Docker daemon is running
   - Verify Jenkins user is in docker group
   - Check Dockerfile syntax and base image availability

4. **Kubernetes deployment fails**:
   - Check namespace exists: `kubectl get namespaces`
   - Verify image is accessible from cluster
   - Check resource quotas and limits

### Debugging Commands

```bash
# Check Jenkins logs
sudo journalctl -u jenkins -f

# Check Kubernetes pods
kubectl get pods -n development
kubectl describe pod <pod-name> -n development

# Check EKS cluster
kubectl cluster-info
kubectl get nodes

# Check Terraform state
terraform show
terraform state list
```

## 🧹 Cleanup

To destroy all resources:

```bash
# Destroy Terraform infrastructure
cd terraform
terraform destroy

# Remove kubeconfig context
kubectl config delete-context <context-name>
```

## 📚 Additional Resources

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test
4. Submit a pull request

## 📄 License

This project is for educational purposes as part of Virtual Lab Experiment 6.

---

**Happy DevOps! 🚀**