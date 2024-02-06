---
title: "Phoenix webapp starter template"
sidebar_position: 3
---

Template to create a starter [phoenix](https://www.phoenixframework.org/) web app

> https://github.com/ranuzz/phoenix-elixir-starter

<!-- truncate -->

## Build Steps

used to create this template

### Install Elixir

https://elixir-lang.org/install.html

### Install phoenix

```
mix archive.install hex phx_new
```

### Create a new project

```
mix phx.new starter
cd starter

```

### DB setup

- Install [postgres](https://www.postgresql.org/download/)
- Create `starter_dev` db
- Edit `config/dev.exs` if running postgres on a different port

```elixir
# Configure your database
config :starter, Starter.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "starter_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  port: 6432
```

- run `mix ecto.create`

## Start server

run phoenix app and verify that everything is working `mix ecto.create`

[localhost](http://localhost:4000/)

## [Step 1] Add auth

Generate `Account` context and `users` table along with auth code.

```
mix phx.gen.auth Accounts User users
mix deps.get
mix ecto.migrate
```

auth generation adds two tables `users` and `user_tokens`. The `user` table only contains three columns

- email
- hashed_password
- confirmed_at
  but can be extended to add more columns or etended to support [multitenancy model](https://blitzjs.com/docs/multitenancy)

This includes routes, pages and logic to

- register user
- login user
- changing email and password

## [Step 2] UUID as id

change the migration file `priv/repo/migrations/<>_name.exs` to remove default integer `id` primary key and add `id` column that is of type `uuid`

```elixir
    create table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
```

update all references and add type option

```elixir
    create table(:users_tokens, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false)
```

in model schema files add following line to indicate how to autogenerate `uuid`

`lib/starter/accounts/user.ex`
`lib/starter/accounts/user_token.ex`

```elixir
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema ".....
```

add type info in any references in schema
`lib/starter/accounts/user_token.ex`

```elixir
  schema "users_tokens" do
    field(:token, :binary)
    field(:context, :string)
    field(:sent_to, :string)
    belongs_to(:user, Starter.Accounts.User, type: :binary_id)
```

reset DB and run migration again

```
mix ecto.migrate
```

## [Step 3] Add seed data

`priv/repo/seeds.exs`

```elixir
# Cleanup tables
Starter.Repo.delete_all(Starter.Accounts.User)
Starter.Repo.delete_all(Starter.Accounts.UserToken)

Starter.Accounts.register_user(%{
  email: "email@example.com",
  password: "paswordpaswordpasword"
})
```

execute seed file

```
mix run priv/repo/seeds.exs
```

Verify data by running the service in repl

```
iex -S mix phx.server
```

```elixir
iex(1)> Starter.Repo.all(Starter.Accounts.User)
[debug] QUERY OK source="users" db=7.3ms decode=1.2ms queue=1.2ms idle=1816.0ms
SELECT u0."id", u0."email", u0."hashed_password", u0."confirmed_at", u0."inserted_at", u0."updated_at" FROM "users" AS u0 []
↳ :elixir.eval_external_handler/3, at: src/elixir.erl:396
[
  #Starter.Accounts.User<
    __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
    id: "1e1cf2d7-912b-48c8-8723-a15123eb7797",
    email: "email@example.com",
    confirmed_at: nil,
    inserted_at: ~U[2024-01-18 11:24:35Z],
    updated_at: ~U[2024-01-18 11:24:35Z],
    ...
  >
]
```

## [Step 4] UI changes

### Install daisyUI

```
cd assets
npm init # accept all default options
npm i -D daisyui@latest
```

add `daisyui` as plugin in tailwind config `assets/tailwind.config.js`

```js
plugins: [
  ...,
  require("daisyui")
]
```

### Add app components

create a new component file `lib/starter_web/components/library_components.ex`

```elixir
defmodule StarterWeb.LibraryComponents do
  use Phoenix.Component

  slot(:left_actions, default: nil)
  slot(:middle_actions, default: nil)
  slot(:right_actions, default: nil)

  def navbar(assigns) do
    ~H"""
    <div class="navbar bg-primary min-h-[48px] max-h-[48px]">
      <div class="navbar-start">
        <img alt="starter logo" src="/images/logo.svg" class="w-[48px] h-[48px]" />
        <%= render_slot(@right_actions) %>
      </div>
      <div class="navbar-center">
        <%= render_slot(@middle_actions) %>
      </div>
      <div class="navbar-end">
        <%= render_slot(@left_actions) %>
      </div>
    </div>
    """
  end

  slot(:inner_block, required: true)

  def content_placeholder(assigns) do
    ~H"""
    <div class="hero">
      <div class="hero-content text-center">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end

```

register the components

`lib/starter_web.ex`

```elixir
  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import StarterWeb.CoreComponents
      import StarterWeb.LibraryComponents
      import StarterWeb.Gettext
```

### Update existing templates

`lib/starter_web/components/layouts/app.html.heex`

```html
<main class="px-4 py-20 sm:px-6 lg:px-8">
  <div class="mx-auto"><%= @inner_content %></div>
</main>
```

`lib/starter_web/controllers/page_html/home.html.heex`

```html
<.flash_group flash={@flash} />
<.content_placeholder>
    <div>Home Page</div>
</.content_placeholder>
```

Add navbar to root template

`lib/starter_web/components/layouts/root.html.heex`

Replace the `ul` with the `navbar` component

```html
<.navbar>
  <:right_actions>
  </:right_actions>
  <:middle_actions>
  </:middle_actions>
  <:left_actions>
    <%= if @current_user do %>
      <li class="text-[0.8125rem] leading-6 text-zinc-900">
        <%= @current_user.email %>
      </li>
      <li>
        <.link
          href={~p"/users/settings"}
          class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
        >
          Settings
        </.link>
      </li>
      <li>
        <.link
          href={~p"/users/log_out"}
          method="delete"
          class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
        >
          Log out
        </.link>
      </li>
    <% else %>
      <li>
        <.link
          href={~p"/users/register"}
          class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
        >
          Register
        </.link>
      </li>
      <li>
        <.link
          href={~p"/users/log_in"}
          class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
        >
          Log in
        </.link>
      </li>
    <% end %>
  </:left_actions>
</.navbar>
```

The app's home page should look like this:

![sample run](https://github.com/ranuzz/phoenix-elixir-starter/assets/1070398/fdb9dbed-bf05-490f-b6e8-d7511ed37d89)

use daisyUI theme/component and tailwind to improve further

## [Step 5] Deploy using fly.io

fly.io supports phoenix application out-of-the-box so just follow the lates documentation

> https://fly.io/docs/elixir/getting-started/

The docker image build might fail. This happens if you have node_modules installed in `assets`, like `daisyUI` in this template.

To fix add following lines in your fly generated `Dockerfile` and run `fly deploy`

after `# install build dependencies` step

```dockerfile
# node and npm for assets
RUN apt-get update && apt-get install -y nodejs
RUN apt-get update && apt-get install npm -y
```

afetr `COPY assets assets` step

```dockerfile
# compile assets npm packages
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error
```

The sample is not included in this repo.
