FROM python:3.9-slim
RUN pip3 install --upgrade pip setuptools
RUN pip3 install mkdocs
RUN apt-get update && apt-get install -y tar

WORKDIR /app

COPY mkdockerize.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
