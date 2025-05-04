# Cookiecutter for Go REST APIs

This project provides a robust foundation for building Go REST API applications. It serves as a template for creating, managing, and extending functionality for various use cases. The included example application demonstrates a simple note management system, allowing users to create, update, delete, and retrieve notes with images. This example can be easily adapted to suit more complex scenarios, making it an ideal starting point for your next Go-based API project.

## Features

* HTTP Server
* JSON and Form Data Support
* Configuration Management
* PostgreSQL Integration
* Database Migrations
* Authentication
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
* `cmd/api`: Contains the main entry point and HTTP router setup for the application.
   * `main.go`: The primary entry point for initializing the application, configuring the router, and ensuring all dependencies are properly set up.
   * `server.go`: Handles the configuration and initialization of the HTTP server with graceful shutdown.
   * `routes.go`: Defines the API routes and their corresponding handlers, ensuring alignment with the OpenAPI specification.
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

1. **Go**: Version 1.23 or later.
2. **PostgreSQL**: A running PostgreSQL instance for database operations (not required for local development).
3. **Docker**: For containerized local testing and deployment.
4. **Python**: Version 3.7 or later for running integration tests.
5. **Terraform**: Version 1.0 or later for infrastructure management.
6. **AWS CLI**: Configured with credentials for deploying to AWS.
7. **Node.js and npm**: For building the OpenAPI specification.
8. **Make**: For running predefined build and deployment commands.
9. **golang-migrate**: For managing database migrations.
10. **jq**: For processing JSON data in scripts.
11. **Swagger Codegen**: A tool for generating API clients and models from the OpenAPI specification.

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

### Important Notes for API Updates

When making changes to the API, keep the following in mind:

1. **Updating Paths**: If you add or modify API paths, ensure that the changes are manually reflected in the API router. This step is crucial to ensure the new or updated endpoints are properly registered and functional.

2. **Adding Definitions and Parameters**: When introducing new definitions or parameters in the API specification, verify that the corresponding generated data types are correctly integrated into the application. Ensure these data types are properly handled for both incoming requests and outgoing responses.

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

### Logs

The application generates logs that can be found in the `local/application.log` file. 

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
   terraform init
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

## Best Practices for Integrating with Web, Mobile, or Other Client Applications

The API specification is a powerful tool for generating client libraries for virtually any platform. To maximize its utility, we recommend maintaining the specification in a dedicated repository and integrating it into your client projects using one of the following approaches:

1. **Git Submodules**: This approach is cleaner and more efficient, as it allows you to reference the specification repository directly. Submodules enable you to fetch the latest version automatically during builds, ensuring your clients always stay up-to-date.

2. **Git Subtree**: If the specification is stored in a private repository and your build process occurs on an external service (e.g., AWS Amplify) where granting repository access is challenging, using a subtree is a practical alternative. This method embeds a copy of the specification repository into your project, eliminating the need for external access during builds.

Both methods have their advantages, so choose the one that best fits your workflow and infrastructure constraints.

## Acknowledgements

This architecture draws inspiration from the excellent book [Let's Go Further](https://lets-go-further.alexedwards.net/) by Alex Edwards.
