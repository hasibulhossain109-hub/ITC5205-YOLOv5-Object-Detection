# ITC5205 Assignment 2 – AWS YOLOv5 Object Detection System

**Student:** Hasibul Hossain Shanto  
**Student ID:** 250135

## Project overview

This project implements a cloud-based object detection workflow using YOLOv5 and AWS. A client sends an image reference to an Amazon API Gateway REST endpoint. API Gateway invokes an AWS Lambda container function, which downloads the source image from Amazon S3, performs YOLOv5 inference, uploads the annotated result to an S3 `output/` location, and records request metadata in an Amazon DynamoDB table named `ObjectDetections`. The Lambda container image is stored in Amazon ECR.

## Architecture

![AWS YOLOv5 architecture](docs/architecture_yolov5_aws.png)

Main services used:

- Amazon S3 – input and output image storage
- Amazon API Gateway – REST API endpoint (`POST /detect`)
- AWS Lambda – serverless YOLOv5 inference
- Amazon ECR – Lambda container image repository
- Amazon DynamoDB – request and output metadata
- AWS IAM – service permissions and least-privilege access
- Amazon EC2 – development and Docker build environment
- Amazon CloudWatch – Lambda execution logs and monitoring

## Repository structure

```text
.
├── code/
│   ├── Dockerfile
│   └── lambda_function.py
├── deploy/
│   ├── deploy.sh
│   └── invoke.sh
├── docs/
│   └── architecture_yolov5_aws.png
├── .gitignore
└── README.md
```

The YOLOv5 source directory and `yolov5n.pt` model are deliberately excluded from Git because they are external/large dependencies. `deploy/deploy.sh` downloads them automatically when preparing the Docker build context.

## Lambda input

The function expects a JSON event containing the S3 bucket and object key:

```json
{
  "bucket": "YOUR_BUCKET_NAME",
  "key": "input/example.jpg"
}
```

## Lambda output

A successful invocation returns HTTP-style status information and the generated S3 output key:

```json
{
  "statusCode": 200,
  "body": "{\"request_id\":\"...\",\"input_image\":\"input/example.jpg\",\"output_image\":\"output/.../input.jpg\"}"
}
```

The DynamoDB table stores:

- `request_id` – unique request identifier (partition key)
- `input_image` – original S3 object key
- `output_image` – generated result object key

## Deployment prerequisites

The build host requires Docker, Git, curl, AWS CLI, and an AWS identity/instance role with permission to authenticate to and push images to the target ECR repository.

The AWS environment should already contain:

- ECR repository: `yolov5-lambda`
- Lambda execution role with CloudWatch Logs, required S3 access, and `dynamodb:PutItem`
- DynamoDB table: `ObjectDetections`
- S3 bucket containing the `input/` object(s)
- Lambda environment variable: `TABLE_NAME=ObjectDetections`
- API Gateway REST resource: `POST /detect`

## Build and push the Lambda container

From the repository root:

```bash
chmod +x deploy/deploy.sh
REGION=us-east-1 REPOSITORY=yolov5-lambda ./deploy/deploy.sh
```

After the image is pushed, deploy the newest ECR image to the Lambda function in the AWS console.

## Invoke the deployed API

Do **not** commit a live unauthenticated API URL to a public repository. Supply it at runtime:

```bash
chmod +x deploy/invoke.sh
ENDPOINT="https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/detect" \
BUCKET="YOUR_BUCKET_NAME" \
KEY="input/example.jpg" \
./deploy/invoke.sh
```

## Expected workflow

1. Client sends the S3 bucket and input object key to `POST /detect`.
2. API Gateway invokes the Lambda function.
3. Lambda downloads the image from S3 to `/tmp/input.jpg`.
4. YOLOv5 runs object detection using `yolov5n.pt`.
5. The annotated image is uploaded to `output/<request-id>/input.jpg` in S3.
6. Request metadata is written to the `ObjectDetections` DynamoDB table.
7. Lambda returns the request ID and output image key.

## Security note

No AWS access keys, private keys, `.pem` files, passwords, or other credentials should be committed to this repository. If the API endpoint is publicly accessible without authorization, keep the live URL out of the public repository and disable or secure it after assessment testing to avoid unintended invocation costs.
