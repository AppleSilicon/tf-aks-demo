# Create VPC, aks (ARM64 instances), HTTP Server using Terraform

## Prerequisites
- AWS CLI
- kubectl
- Docker
- Python 3
- Terraform

## Step 1 - AWS CLI Login
1. Go to AWS Console, create a Access Key
1. open a Command Prompt / Terminal
```
aws configure

$ aws configure
AWS Access Key ID [None]: YOUR_ACCESS_KEY_ID
AWS Secret Access Key [None]: YOUR_SECRET_ACCESS_KEY
Default region name [None]: ap-east-1
Default output format [None]: json
```

## Step 2 - Create the VPC and aks
```
cd vpc-aks-s3

terraform init
terraform plan
terraform apply
```

It will take ~10min to create about 60 resources on AWS. 

Update the kubeconfig
```
aws aks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

## Step 3 - Create a ECR
Go to AWS Console, create a ECR with namespace/repo-name = demo/ecr

Retrieve an authentication token and authenticate your Docker client to your registry. Use the AWS CLI:

```
aws ecr get-login-password --region ap-east-1 | docker login --username AWS --password-stdin awsid.dkr.ecr.ap-east-1.amazonaws.com
```

## Step 4 - Python HTTP Server

1. Build the Docker image of the http Server

```
cd ../http-server
docker buildx build . --platform=linux/arm64,linux/amd64 -t demo/ecr:latest
```

2. tag and push the Docker image to a ECR

```        
docker tag demo/ecr:latest <userid>.dkr.ecr.ap-east-1.amazonaws.com/demo/ecr:latest

docker push <userid>.dkr.ecr.ap-east-1.amazonaws.com/demo/ecr:latest
```
## Step 5 - Use Terraform to deploy the HTTP Server to the aks
1. Edit http-server.tf, give the correct URL of the Docker image you just pushed to ECR

```
image: <userid>.dkr.ecr.ap-east-1.amazonaws.com/demo/ecr:latest
```

2. Terraform apply
```
terraform init
terraform plan
terraform apply
```

## Step 6 - Verification of the deployed Python app being accessible through the service.

```
LOAD_BALANCER_IP=$(kubectl get service -n aks-demo http-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$LOAD_BALANCER_IP
```

## Step 7 - Destroy the resources
```
cd ../vpc-aks-s3
terraform destroy
```

That's it. Thx!