# How to Set Up AWS, Redis, and RabbitMQ Services Locally

## Contents

- [Localstack](#localstack)
- [AWS Services](#aws-services)
- [Secret Manager](#secret-manager)
- [Simple Queue Service](#simple-queue-service)

## Service Setup Guide

### Localstack

1. Install **Localstack** on your machine. [Localstack Installation Guide](https://docs.localstack.cloud/getting-started/installation/)

2. Create a `docker-compose.yml` file in a directory that will contain all the configuration related to the creation of the services.

3. Open the `docker-compose.yml` file and define the AWS services to be deployed in **Localstack**, as shown below:

   ```yaml
   services:
     localstack:
       container_name: "${LOCALSTACK_DOCKER_NAME:-localstack-main}"
       image: localstack/localstack
       ports:
         - "127.0.0.1:4566:4566" # LocalStack Gateway
         - "127.0.0.1:4510-4559:4510-4559" # external services port range
       environment:
         # LocalStack configuration: https://docs.localstack.cloud/references/configuration/
         - SERVICES=sqs,secretsmanager
         - DEBUG=${DEBUG:-0}
         - AWS_ACCESS_KEY_ID=test # default AWS credentials
         - AWS_SECRET_ACCESS_KEY=test # default AWS credentials
         - PERSISTENCE=1 # enable persistence
       volumes:
         - "${LOCALSTACK_VOLUME_DIR:-./volume}:/var/lib/localstack" # LocalStack data volume
         - "/var/run/docker.sock:/var/run/docker.sock" # required for launching Docker containers from within LocalStack
   ```

   **Note:** This configuration is based on the [Localstack Docker Compose Guide](https://docs.localstack.cloud/getting-started/installation/#docker-compose).

4. Run `docker-compose up` in your terminal to start the containers with the specified services.

---

## AWS Services

**IMPORTANT:** The values used here are for TESTING purposes only. Please validate the correct operation and consumption of AWS services in DEVELOP, STAGING, and PRODUCTION environments.

### Secret Manager

#### Create a Secret

1. Before creating a secret, you need to create a `secret.json` file with the data to be stored. You can create it as follows:

   ```
   echo {"secret": "xyz","secret2": "xyz"} > secret.json
   ```

2. From the command line, run the following command:

   ```
   awslocal --endpoint-url=http://localhost:4566 secretsmanager create-secret --name secret_name --description "Secret" --secret-string file://secret.json
   ```

   **Note:** Run this command in the same directory where the `secret.json` file is located.

3. After creating the secret, you will see output similar to the following:

   ```
   {
       "ARN": "arn:aws:secretsmanager:us-east-1:000000000000:secret:secret_name-pyfjVP",
       "Name": "secret_name",
       "VersionId": "a50c6752-3343-4eb0-acf3-35c74f00f707"
   }
   ```

### Simple Queue Service

#### Create a Queue

1. From the command line, run the following command:

   ```
   awslocal sqs create-queue --queue-name sqs_name
   ```

2. After creating the SQS queue, you will see output similar to the following:

   ```
   {
       "QueueUrl": "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/sqs_name"
   }
   ```

---
