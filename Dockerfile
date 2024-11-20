FROM python:3-alpine3.12

RUN apk update && apk upgrade

COPY requirements.txt .

RUN pip install -r requirements.txt

WORKDIR app/

COPY app.py .

CMD ["python", "app.py"]
