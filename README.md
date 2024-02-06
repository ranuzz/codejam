# Codejam

Streamline your workflow with collaborative code planning & live documentation.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

- Elixir/Erlang

[Official Documentation](https://elixir-lang.org/install.html)

Verify

```
elixir -v
```

Versions

```
Erlang/OTP 26
Elixir 1.15.7
```

- Phoenix

```
mix archive.install hex phx_new
```

version

```
:phoenix, "~> 1.7.9"
```

- PostgreSQL

[Official Documentation](https://www.postgresql.org/download/)

version

```
PostgreSQL 16
```

### Installing

Run `mix setup` to install and setup dependencies

### GitHub App

[Create a GitHub OAuth2 app](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/creating-an-oauth-app)

### Env variables

Create a local copy of env variables and fill in the values
`cp codejam/dev/.env.sh codejam/dev/env.sh`

Export them before running the app or include them in the shell rc file

### Running

start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Deployment

Ready to run in production?
TBD

## Resources

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
