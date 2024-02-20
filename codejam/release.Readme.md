# Release command log

## Command

```
mix phx.gen.release --docker
```

## Generated files

- creating rel/overlays/bin/server
- creating rel/overlays/bin/server.bat
- creating rel/overlays/bin/migrate
- creating rel/overlays/bin/migrate.bat
- creating lib/codejam/release.ex
- creating Dockerfile
- creating .dockerignore

Your application is ready to be deployed in a release!

## Useful commands

### To build a release

```
mix release
```

### To start your system with the Phoenix server running

```
\_build/dev/rel/codejam/bin/server
```

### To run migrations

```
\_build/dev/rel/codejam/bin/migrate
```

### Once the release is running you can connect to it remotely:

```
_build/dev/rel/codejam/bin/codejam remote
```

### To list all commands:

```
_build/dev/rel/codejam/bin/codejam
```

## references

- See https://hexdocs.pm/mix/Mix.Tasks.Release.html for more information about Elixir releases.
- For more information about deploying with Docker see https://hexdocs.pm/phoenix/releases.html#containers
