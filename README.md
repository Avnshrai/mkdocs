## Dockerfile

This Dockerfile sets up a Docker image for running an mkdocs server.

# Instructions

1. Build the Docker image by running the following command:

```shell
FROM python:3.9-slim
RUN pip3 install --upgrade pip setuptools
RUN pip3 install mkdocs
RUN apt-get update
RUN apt-get -y install zip
RUN mkdir app
WORKDIR /app
EXPOSE 8000
ENTRYPOINT ["mkdocs", "serve", "--dev-addr=0.0.0.0:8000", "-f"]
CMD ["/app/mkdocs.yml"]
```
