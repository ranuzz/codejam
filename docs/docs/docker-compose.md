---
title: "Docker compose for Phoenix project"
sidebar_position: 3
---

Line by line explanation of how to write a docker compose file for phoenix project for local development and testing. Prepare the application for release by following official [documentation](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Release.html)

<!-- truncate -->

[docker compose](https://docs.docker.com/compose/) is primarily meant for local development and testing although as per the official documentation there is plan to create prodcution ready version. An environment created by docker compose very much resembels a k8s cluster and behaves the same way in terms of deployment, scaling and networking.

`version` is an informative tag used to specify the schema version supported by the file. docker doesn't use this to validate the file syntax, this is an optional parameter included for backward compatibility

`name` specify the project name using this top level config. The project can be included in service environemnt using variable COMPOSE_PROJECT_NAME

`services` defines a list of container that are supposed to run as part of compose deployment. For a full stack phoenix application, one service is defined to run the phoenix container and another to run the database.

```
# name of the service
codejam_phoenix:
    # name or tag for the image of the service
    image: codejam/phoenix
    # build steps. for development purposes build the image form the
    # local codebase.
    build:
      # context points to the base path of phoenix application code
      # depending on the directory structure the it could be . or relative path
      context: ./codejam
      # name of the dockerfile if it is not the default name
      dockerfile: codejam.dev.Dockerfile
    # name of the container that you can look up in docker dashboard or CLI output
    container_name: codejam_phoenix
    # environment variables required to run the application
    env_file: ./codejam/dev/.env
    # additional environment variable with values passed inline
    environment:
      APP_ENV: development
    # forward the application port 4000 to host machine
    ports:
      - "4000:4000"
    volumes:
      - codejam-data:/tmp/codejam-data
    networks:
      - codejam_network
    # make sures that the container will be restarted in case of an error
    # but will stay stopped if explicitly killed
    restart: unless-stopped
    # name service on which this application should depend and wait on
    depends_on:
      codejam_postgres:
        condition: service_healthy
        restart: true
      codejam_minio:
        condition: service_started
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 1m30s
      timeout: 10s
      retries: 3
```

```
  # postgres database for the application
  codejam_postgres:
    # pull the image from repository instead of building
    image: postgres:16.2
    container_name: codejam_postgres
    environment:
      # for local development run db in trust mode and without password
      - POSTGRES_HOST_AUTH_METHOD=trust
      # define the name of the database
      - POSTGRES_DB=codejamdb
    ports:
      - "7432:5432"
    networks:
      - codejam_network
    restart: unless-stopped
    # health check lets compose know that service is up
    # and it is safe to start dependant services
    healthcheck:
      test: ["CMD", "pg_isready"]
      interval: 1m30s
      timeout: 10s
      retries: 3
```

`networks`

define internal network that will be used by the containers in deployment to discover and connect to other services

```
networks:
  codejam_network:
    driver: bridge
```

`volumes`

persistent data volumes for the services, if required

```
volumes:
  codejam-data:
  codejam-minio-data:
```
