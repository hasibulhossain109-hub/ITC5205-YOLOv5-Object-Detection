import json
import os
import subprocess
import uuid

import boto3

s3 = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ.get("TABLE_NAME", "ObjectDetections")


def lambda_handler(event, context):
    try:
        bucket = event["bucket"]
        key = event["key"]
        request_id = str(uuid.uuid4())

        # Store the downloaded object using a YOLO-compatible image extension.
        filename = "input.jpg"
        input_path = "/tmp/input.jpg"
        output_dir = f"/tmp/{request_id}"

        s3.download_file(bucket, key, input_path)
        os.makedirs(output_dir, exist_ok=True)

        cmd = [
            "python",
            "/var/task/yolov5/detect.py",
            "--weights",
            "/var/task/yolov5n.pt",
            "--source",
            input_path,
            "--project",
            output_dir,
            "--name",
            "result",
            "--exist-ok",
            "--save-txt",
        ]
        subprocess.run(cmd, check=True)

        detected_file = f"{output_dir}/result/{filename}"
        output_key = f"output/{request_id}/{filename}"
        s3.upload_file(detected_file, bucket, output_key)

        table = dynamodb.Table(TABLE_NAME)
        table.put_item(
            Item={
                "request_id": request_id,
                "input_image": key,
                "output_image": output_key,
            }
        )

        return {
            "statusCode": 200,
            "body": json.dumps(
                {
                    "request_id": request_id,
                    "input_image": key,
                    "output_image": output_key,
                }
            ),
        }

    except Exception as e:
        print(e)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
        }
