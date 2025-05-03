# Cookiecutter for Go REST APIs

This project serves as a starting point for building Go REST API applications. It is a file-sharing application where users own directories and files, and other users can request access to view or modify them.

## Features

* HTTP Server
* JSON and Form Data Support
* Configuration Management
* PostgreSQL Integration
* Database Migrations
* Authentication
* Permission-Based Authorization
* File Upload Handling
* Logging
* Graceful Shutdown
* CORS Support
* Filtering, Sorting, and Pagination
* Rate Limiting
* Metrics Collection
* OpenAPI/Swagger Integration
* Docker Image Support
* Local Testing Setup
* Terraform Infrastructure Management
* AWS Deployment
* Basic Integration Tests

## Project Structure

The project is organized as follows:

* `cmd/api`: Entry point for the HTTP router.
* `internal`: Core library for the API.
    * `data`: Handles database interactions.
    * `swagger`: Contains generated code based on the OpenAPI specification.
    * `utils`: Utility functions for common tasks.
* `migrations`: PostgreSQL migrations generated using `golang-migrate`.
* `local`: Local container setup for the application and database testing.
* `spec`: OpenAPI specification for generating clients and models.
* `terraform`: Infrastructure configuration for deploying the application on AWS.
* `integration`: Integration tests for the API.

## Requirements

To use this project, ensure you have the following installed and configured:

1. **Go**: Version 1.18 or later.
2. **PostgreSQL**: A running PostgreSQL instance for database operations.
3. **Docker**: For containerized local testing and deployment.
4. **Docker Compose**: For orchestrating multi-container applications.
5. **Python**: Version 3.7 or later for running integration tests.
6. **Terraform**: Version 1.0 or later for infrastructure management.
7. **AWS CLI**: Configured with credentials for deploying to AWS.
8. **Node.js and npm**: For building the OpenAPI specification.
9. **Make**: For running predefined build and deployment commands.
10. **golang-migrate**: For managing database migrations.
11. **jq**: For processing JSON data in scripts.

Ensure all dependencies are properly installed and accessible in your system's PATH.

## Updating the API Specification

To update the API specification, follow these steps:

1. Navigate to the `spec` directory and build the specification:
   ```bash
   cd spec
   npm install
   npm build
   cd ..
   ```
2. Update the API models and test clients:
   ```bash
   make codegen-api
   make codegen-tests
   ```

## Testing Locally

To test the application locally, you need to configure access to an AWS bucket for file uploads and downloads. Follow these steps:

1. Create a file named `.env` in the `local` directory with the following content:
   ```plaintext
   AWS_ACCESS_KEY_ID=<Your AWS Access Key ID>
   AWS_SECRET_ACCESS_KEY=<Your AWS Secret Access Key>
   APP_BUCKET=<Name of the S3 Bucket for File Operations>
   ```

2. Alternatively, if you prefer not to create the bucket manually, you can deploy the `dev` environment using Terraform. Once deployed, use the bucket name generated during the deployment process.

This setup ensures the application has the necessary credentials and bucket information to perform file operations locally.

### Running Integration Tests

To run the integration tests, navigate to the `integration` directory and execute the following commands:

```bash
pip install -r requirements.txt
make tests
```

**Note**: While using a virtual environment (e.g., `virtualenv`) is recommended for isolating dependencies, it is not mandatory.

### Cleaning Up

To reset your local database, run the following command:

```bash
make reset
```

**Note**: Additionally, we recommend cleaning up any files uploaded to your S3 bucket. These files upload during local testing are located in a directory named `local`.

## Deploying Infrastructure and Application

### Prerequisites for Infrastructure Deployment

Before deploying the infrastructure, ensure you have a provisioned PostgreSQL database. We recommend using a cost-effective service like [Railway](https://railway.app/) or any other provider of your choice. The only requirement is access to the database URL for establishing a connection. Note that we avoided creating the database in AWS to minimize costs.

### Environment-Specific Configuration

The `backend` Terraform module is designed to be reusable across multiple environments. The `dev` and `prod` directories correspond to their respective environments, allowing you to manage configurations and deployments independently for development and production.

### Steps to Deploy

1. Navigate to the `terraform` directory:
   ```bash
   cd terraform
   ```

2. Choose the environment directory you want to deploy (e.g., `dev` or `prod`):
   ```bash
   cd <environment>
   ```

3. Create a file named `env.tfvars` with the following content:
   ```hcl
   user_id     = "<Your AWS User ID for uploading the image to ECR>"
   db_url      = "<Your PostgreSQL connection URL>"
   environment = "<Environment name (e.g., dev or prod)>"
   ```

4. Deploy the infrastructure using Terraform:
   ```bash
   terraform apply -var-file="env.tfvars"
   ```

This process sets up the necessary infrastructure for the selected environment.

### Handling First Deployment

The initial infrastructure deployment will fail because no image is available in AWS App Runner. To resolve this:

1. Publish the application image:
   ```bash
   make publish
   ```
   You can specify the environment using the `ENV` variable (e.g., `make publish ENV=prod`).
2. Retry the infrastructure deployment:
   ```bash
   terraform apply -var-file="env.tfvars"
   ```
