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

## Updating the API Specification

To update the API specification, follow these steps:

1. Navigate to the `spec` directory and build the specification:
   ```bash
   cd spec
   pn build
   cd ..
   ```
2. Update the API models and test clients:
   ```bash
   make codegen-api
   make codegen-tests
   ```

## Deploying Infrastructure and Application

The `backend` module is designed to be reusable for multiple environments. The `dev` and `prod` directories correspond to their respective environments.

### Steps to Deploy

1. Navigate to the directory of the desired environment (e.g., `dev` or `prod`).
2. Create a file named `env.tfvars` with the following content:
   ```hcl
   user_id     = "<AWS User ID for uploading the image to ECR>"
   db_url      = "<PostgreSQL connection URL>"
   environment = "<Environment name (e.g., dev or prod)>"
   ```
3. Deploy the infrastructure:
   ```bash
   terraform apply -var-file="env.tfvars"
   ```

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
