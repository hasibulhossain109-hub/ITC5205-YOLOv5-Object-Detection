ITC5205 Assignment 2 - AWS YOLOv5 Object Identification System
Student: Hasibul Hossain Shanto
Student ID: 250135

Project summary:
This project implements a cloud-based image object identification workflow using YOLOv5 on AWS. Images are stored in Amazon S3. A REST API in Amazon API Gateway invokes a container-based AWS Lambda function. The Lambda function downloads an input image from S3, performs YOLOv5 inference, writes the detected output image back to S3, and records request metadata in the ObjectDetections DynamoDB table. The Lambda container image is stored in Amazon ECR and was built/tested on an Amazon EC2 instance.

Live endpoint:
https://8bbav0shha.execute-api.us-east-1.amazonaws.com/prod/detect

Example POST body:
{"bucket":"itc5205-yolov5-shanto","key":"input/test3.jfif"}

