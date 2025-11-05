#!/bin/bash

AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="<SEU_ID_AWS_12DIGITOS>"
ECR_BACKEND="app-task-backend"
ECR_FRONTEND="app-task-frontend"

echo "=== Login no ECR ==="
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo "=== Build Backend ==="
docker build -t $ECR_BACKEND:latest ./backend

echo "=== Tag Backend ==="
docker tag $ECR_BACKEND:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_BACKEND:latest

echo "=== Push Backend ==="
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_BACKEND:latest

echo "=== Build Frontend ==="
docker build -t $ECR_FRONTEND:latest ./frontend

echo "=== Tag Frontend ==="
docker tag $ECR_FRONTEND:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_FRONTEND:latest

echo "=== Push Frontend ==="
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_FRONTEND:latest

echo "=== Deploy completo! ==="
