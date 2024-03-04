# Codejam

Boost your team's coding productivity with Codejam, the collaborative workspace for developers. Discuss, plan, debug, and annotate code together in real-time, keeping your projects on track.

Here's what sets Codejam apart:

- **Streamlined code documentation**: Add and update comments collaboratively, ensuring everyone has access to the latest information.
- **Seamless onboarding**: Create interactive walkthroughs and tutorials directly within your codebase, empowering new team members to get up to speed quickly.
- **Actionable code reviews**: Make TODOs, FIXMEs, and NOTES actionable by assigning owners and setting reminders, keeping tasks organized and accountable.
- **Real-time collaboration**: Debug faster with instant feedback and code reviews, fostering a dynamic and efficient development environment.

Codejam helps your team collaborate effectively, stay organized, and ship high-quality code faster.

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

### docker compose

make sure the `SECRET_KEY_BASE` is set in `compose.yaml`

```
docker compose up
docker compose down
```

## Deployment

Ready to run in production?
TBD

## Resources

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
