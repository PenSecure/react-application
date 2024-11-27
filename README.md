# react-and-spring-data-rests- tester

The application has a react frontend and a Spring Boot Rest API, packaged as a single module Maven application. You can build the application using maven and run it as a Spring Boot application using the flat jar generated in target (`java -jar target/*.jar`).

You can test the main API using the following curl commands (shown with its output):

---

To see the frontend, navigate to <aws-alb-url/login>. You are immediately redirected to a login form. Log in as `greg/turnquist`



# Deployment Guide for Pensmart Cloud Solution

This guide provides detailed, step-by-step instructions on how to fork, configure, and deploy the Pensmart solution to your own cloud environment. For demonstration purposes, AWS Cloud was used as the platform, leveraging **Terraform**, a cloud-agnostic Infrastructure-as-Code (IaC) tool, for automated provisioning.

---

## Prerequisites

Before you begin, ensure you have the following:

1. **AWS Account**: Create an account if you don’t already have one.
2. **IAM User with Administrator Privileges**: Create an IAM user with administrative access to avoid access-related issues. Generate an **Access Key ID** and **Secret Access Key** for API interactions.
3. **Secrets and Parameters**: 
   - Manually create required secrets and parameters in **AWS Parameter Store** or **AWS Secrets Manager**, as outlined in this guide.
4. **S3 Bucket**: Set up a manual S3 bucket with public access for storing state files.
5. **DynamoDB Table** *(Optional)*: Create a DynamoDB table for state locking to ensure only one user can apply changes at a time.
6. **Git**: Install Git on your local machine.
7. **Terraform**: Install the latest version of Terraform by following this [installation guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

   After installation, set your AWS credentials as environment variables:
   ```bash
   export AWS_ACCESS_KEY_ID="your-access-key-id"
   export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
   ```

---

## Deployment Instructions

For this demonstration, the **us-west-1** AWS region is used. If you prefer a different region, update the value in `vars/dev.tfvars`.

### Step 1: Clone the Repository and Initialize Terraform

1. Clone the project:
   ```bash
   git clone [_URL]
   cd pensmart-project
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Create a new workspace:
   ```bash
   terraform workspace new <dev>
   # Replace <dev> with the desired environment name (e.g., staging, production)
   ```

4. Plan your infrastructure:
   ```bash
   terraform plan -var-file=vars/dev.tfvars -out=pensmart.tfplan
   ```

5. Apply the plan to provision resources:
   ```bash
   terraform apply "pensmart.tfplan"
   ```

6. Wait for the process to complete. Terraform will provision all required infrastructure components.

---

## Project Structure

The Terraform scripts are organized as follows:

```
pensmart-project/
├── .terraform/
├── modules/
│   ├── acm/             # SSL/TLS certificate configuration
│   ├── ecr/             # Amazon Elastic Container Registry
│   ├── ecs/             # Amazon ECS service
│   ├── lb/              # Load Balancer setup
│   ├── postgresql/      # RDS PostgreSQL database
│   └── vpc/             # Virtual Private Cloud configuration
├── vars/
│   └── dev.tfvars       # Environment-specific variables
├── .terraform.lock.hcl  # Lock file for Terraform dependencies
├── main.tf              # Main entry point for Terraform configuration
├── output.tf            # Outputs after applying Terraform
├── pens.tfplan          # Terraform plan file
├── provider.tf          # AWS provider configuration
└── variables.tf         # Variable definitions
```

---

## Triggering the CI/CD Pipeline for Application Deployment

The solution uses **GitHub Actions** for its CI/CD pipeline. The pipeline is configured to deploy the application to ECS upon a push to the `main` branch.

### Steps to Trigger the Pipeline:

1. **Fork the Repository**: 
   - Repository URL: [https://github.com/PenSecure/spring-service](https://github.com/PenSecure/spring-service)

2. **Set Up GitHub Secrets**:
   - Add the following secrets in your forked repository settings:
     - `AWS_ACCESS_KEY_ID`
     - `AWS_SECRET_ACCESS_KEY`

3. **Clone Your Forked Repository**:
   ```bash
   git clone <your-forked-repo-url>
   cd spring-service
   ```

4. **Make a Change**:
   - Modify any file (e.g., README.md). The pipeline is configured to trigger on push events.

5. **Push Your Changes**:
   ```bash
   git add .
   git commit -m "Trigger pipeline"
   git push origin main
   ```

6. **Pipeline Execution**:
   - GitHub Actions will automatically trigger the pipeline and deploy the application to the ECS cluster created by Terraform.

---

## Clean-Up Instructions

To delete all provisioned resources and clean up the environment:

1. Navigate to the Terraform working directory:
   ```bash
   cd pensmart-project
   ```

2. Run the following command:
   ```bash
   terraform destroy -var-file=vars/dev.tfvars
   ```

3. Confirm the destruction process when prompted.

---

## Notes

- The provided Terraform scripts are customizable. You can modify them to suit your specific use case.
- If left unchanged, the scripts will create a clean and functional infrastructure for your application.

---

Let me know if you need further adjustments or have specific preferences for this documentation!
