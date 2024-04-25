#!/bin/bash

# Initial checks
if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
  read -e -i "us-east-1" -p "AWS Region: " AWS_DEFAULT_REGION
fi

# Get account ID
AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`

# Download model
if ! [ -f gpt4all-falcon-newbpe-q4_0.gguf ]; then
    curl -L https://gpt4all.io/models/gguf/gpt4all-falcon-newbpe-q4_0.gguf \
         -o ./gpt4all-falcon-newbpe-q4_0.gguf
fi

# and model config for offline usage
if ! [ -f models3.json ]; then
    curl -L https://gpt4all.io/models/models3.json \
         -o ./models3.json
fi

# Build image
docker build --rm -t slambda:latest .

# Login to registry
aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS \
                                                                         --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

# Create new repository
aws ecr create-repository --repository-name slambda \
                          --image-scanning-configuration scanOnPush=true \
                          --image-tag-mutability MUTABLE

# Tag and push image
docker tag slambda:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/slambda:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/slambda:latest

# Create IAM role
aws iam create-role --role-name slambda \
                    --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'

aws iam attach-role-policy --role-name slambda \
                           --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# Create Lambda function
aws lambda create-function --function-name slambda \
                           --description "Run SLMs with AWS Lambda" \
                           --role arn:aws:iam::${AWS_ACCOUNT_ID}:role/slambda \
                           --package-type Image \
                           --code ImageUri=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/slambda:latest \
                           --timeout 300 \
                           --memory-size 10240 \
                           --publish

# Create URL endpoint to the function
aws lambda create-function-url-config --function-name slambda \
                                      --auth-type AWS_IAM \
                                      --invoke-mode RESPONSE_STREAM

# Get function URL
aws lambda get-function-url-config --function-name slambda \
                                   --query FunctionUrl \
                                   --output text
