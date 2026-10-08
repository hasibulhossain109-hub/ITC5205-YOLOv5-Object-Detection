FROM public.ecr.aws/lambda/python:3.12

RUN dnf install -y mesa-libGL libxcb && dnf clean all

COPY yolov5/ /var/task/yolov5/
COPY yolov5n.pt /var/task/yolov5n.pt
COPY lambda_function.py /var/task/

RUN pip install --no-cache-dir torch torchvision \
    --index-url https://download.pytorch.org/whl/cpu
RUN pip install --no-cache-dir -r /var/task/yolov5/requirements.txt

CMD ["lambda_function.lambda_handler"]
