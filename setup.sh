#!/bin/bash

# VLE-6 CI/CD Pipeline Setup Script
# This script helps automate the setup process

set -e

echo "🚀 Starting VLE-6 CI/CD Pipeline Setup"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check if ansible is installed
    if ! command -v ansible &> /dev/null; then
        print_error "Ansible is not installed. Please install Ansible first."
        exit 1
    fi
    
    # Check if aws cli is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        print_warning "kubectl is not installed. It will be installed on the Jenkins server."
    fi
    
    print_status "Prerequisites check completed!"
}

# Setup AWS credentials
setup_aws_credentials() {
    print_status "Checking AWS credentials..."
    
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_status "AWS credentials are configured!"
}

# Create terraform.tfvars
create_terraform_vars() {
    print_status "Setting up Terraform variables..."
    
    if [ ! -f "terraform/terraform.tfvars" ]; then
        cp terraform/terraform.tfvars.example terraform/terraform.tfvars
        print_warning "Created terraform/terraform.tfvars from example. Please update it with your values."
        print_warning "Make sure to set your AWS key pair name in terraform.tfvars"
        
        # Prompt for key pair name
        read -p "Enter your AWS Key Pair name: " key_pair_name
        sed -i "s/your-aws-keypair-name/$key_pair_name/g" terraform/terraform.tfvars
        
        print_status "Updated terraform.tfvars with key pair: $key_pair_name"
    else
        print_status "terraform.tfvars already exists!"
    fi
}

# Deploy infrastructure
deploy_infrastructure() {
    print_status "Deploying infrastructure with Terraform..."
    
    cd terraform
    
    # Initialize Terraform
    terraform init
    
    # Plan the deployment
    terraform plan
    
    # Ask for confirmation
    read -p "Do you want to apply this Terraform plan? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Apply the configuration
        terraform apply -auto-approve
        
        # Get outputs
        jenkins_ip=$(terraform output -raw jenkins_public_ip)
        eks_cluster_name=$(terraform output -raw eks_cluster_name)
        
        print_status "Infrastructure deployed successfully!"
        print_status "Jenkins Server IP: $jenkins_ip"
        print_status "EKS Cluster Name: $eks_cluster_name"
        
        # Update Ansible inventory
        cd ../ansible
        sed -i "s/YOUR_JENKINS_EC2_IP/$jenkins_ip/g" inventory.ini
        
        cd ..
    else
        print_warning "Terraform apply cancelled."
        exit 0
    fi
}

# Configure Jenkins with Ansible
configure_jenkins() {
    print_status "Configuring Jenkins server with Ansible..."
    
    cd ansible
    
    # Test connectivity
    ansible jenkins -m ping
    
    if [ $? -eq 0 ]; then
        print_status "Connection to Jenkins server successful!"
        
        # Run the playbook
        ansible-playbook install-jenkins.yml
        
        print_status "Jenkins configuration completed!"
        print_status "You can access Jenkins at: http://$jenkins_ip:8080"
    else
        print_error "Cannot connect to Jenkins server. Please check your SSH key and security groups."
        exit 1
    fi
    
    cd ..
}

# Setup Kubernetes access
setup_kubernetes() {
    print_status "Setting up Kubernetes access..."
    
    # Update kubeconfig
    aws eks update-kubeconfig --region $(grep aws_region terraform/terraform.tfvars | cut -d'"' -f2) --name $eks_cluster_name
    
    # Apply Kubernetes manifests
    kubectl apply -f k8s/configmap.yaml
    kubectl apply -f k8s/deployment.yaml
    kubectl apply -f k8s/production-deployment.yaml
    
    print_status "Kubernetes setup completed!"
}

# Main execution
main() {
    echo "=============================================="
    echo "  VLE-6 CI/CD Pipeline Automated Setup"
    echo "=============================================="
    
    check_prerequisites
    setup_aws_credentials
    create_terraform_vars
    
    # Ask user what they want to do
    echo ""
    echo "Select an option:"
    echo "1. Deploy full infrastructure (Terraform + Ansible + Kubernetes)"
    echo "2. Deploy infrastructure only (Terraform)"
    echo "3. Configure Jenkins only (Ansible)"
    echo "4. Setup Kubernetes only"
    echo "5. Exit"
    
    read -p "Enter your choice (1-5): " choice
    
    case $choice in
        1)
            deploy_infrastructure
            configure_jenkins
            setup_kubernetes
            ;;
        2)
            deploy_infrastructure
            ;;
        3)
            configure_jenkins
            ;;
        4)
            setup_kubernetes
            ;;
        5)
            print_status "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid choice. Exiting."
            exit 1
            ;;
    esac
    
    echo ""
    print_status "Setup completed! 🎉"
    echo ""
    echo "Next steps:"
    echo "1. Access Jenkins at: http://$jenkins_ip:8080"
    echo "2. Configure Jenkins credentials for Docker Hub and AWS"
    echo "3. Create a new pipeline job using the provided Jenkinsfile"
    echo "4. Update the Docker image name in Jenkinsfile and Kubernetes manifests"
    echo ""
}

# Run the main function
main "$@"