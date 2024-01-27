defmodule CodejamWeb.LibraryComponents do
  @moduledoc """
  Provides codjam library components

  All UI elements must use prebuilt components from
  * Core Components
  * Library Components

  ## Library Design Guidline

  * Font: Noto Sans
  * Icon: Material Symbol [https://fonts.google.com/icons] (and hero icons?)

  ## Sections
  Sectioned based on convention defined in https://daisyui.com/ library
  * Buttons
  * Actions
  * Data Display
  * Navigation
  * Feedback
  * Data Input
  * Layout
  * Mockup
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  Defines a button with color
  """

  attr(:type, :string, default: nil)
  attr(:class, :string, default: "primary")
  attr(:rest, :global, include: ~w(disabled form name value))

  slot(:inner_block, required: true)

  def color_button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "btn",
        "btn-active",
        "btn-sm",
        "btn-" <> @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr(:type, :string, default: nil)
  attr(:class, :string, default: "primary")
  attr(:rest, :global, include: ~w(disabled form name value))
  attr(:icon, :string, default: "home")

  def icon_button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "btn",
        "btn-outline",
        "btn-xs",
        "btn-" <> @class
      ]}
      {@rest}
    >
      <span class="material-symbols-outlined material-symbols-outlined-small">
        <%= @icon %>
      </span>
    </button>
    """
  end

  attr(:href, :string, default: "#")
  attr(:class, :string, default: "primary")

  slot(:inner_block, required: true)

  def link_button(assigns) do
    ~H"""
    <a
      class={[
        "btn",
        "btn-active",
        "btn-sm",
        "mx-[4px]",
        "btn-" <> @class
      ]}
      href={@href}
    >
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  attr(:href, :string, default: "#")
  attr(:class, :string, default: "primary")
  attr(:icon, :string, default: "home")
  attr(:label, :string, default: "home")

  def icon_link_button(assigns) do
    ~H"""
    <div class="tooltip tooltip-bottom" data-tip={@label}>
      <a
        class={[
          "btn",
          "btn-outline",
          "btn-sm",
          "mx-[4px]",
          "mt-[4px]",
          "btn-" <> @class
        ]}
        href={@href}
      >
        <span class="material-symbols-outlined">
          <%= @icon %>
        </span>
      </a>
    </div>
    """
  end

  attr(:src, :string, default: "/images/avatar-placeholder.svg")
  attr(:data, :string, default: nil)

  def avatar_with_ring(assigns) do
    ~H"""
    <div class="avatar">
      <div class="w-[32px] rounded-full ring ring-primary ring-offset-base-100 ring-offset-2">
        <%= if @data do %>
          <img alt="avatar" src={"data:image/jpeg;base64," <> @data} />
        <% else %>
          <img alt="avatar" src={@src} />
        <% end %>
      </div>
    </div>
    """
  end

  slot(:left_actions, default: nil)
  slot(:middle_actions, default: nil)
  slot(:right_actions, default: nil)

  def navbar(assigns) do
    ~H"""
    <div class="navbar bg-primary min-h-[48px] max-h-[48px]">
      <div class="navbar-start">
        <img alt="codejam logo" src="/images/logo.png" class="w-[48px] h-[48px]" />
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

  def title(assigns) do
    ~H"""
    <h1 class="text-4xl font-bold"><%= render_slot(@inner_block) %></h1>
    """
  end

  slot(:inner_block, required: true)

  def sub_title(assigns) do
    ~H"""
    <p class="py-6"><%= render_slot(@inner_block) %></p>
    """
  end

  slot(:inner_block, required: true)

  def hero_title_landing(assigns) do
    ~H"""
    <div class="hero">
      <div class="hero-content text-center">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.search_box_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.search_box_form>
  """
  attr(:for, :any, required: true, doc: "the datastructure for the form")
  attr(:as, :any, default: nil, doc: "the server side parameter to collect all input under")

  attr(:rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"
  )

  slot(:inner_block, required: true)
  slot(:actions, doc: "the slot for form actions, such as a submit button")

  def search_box_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="flex flex-row gap-[8px] space-y-8 bg-secondary">
        <%= render_slot(@inner_block, f) %>

        <div :for={action <- @actions} class="mt-2 flex flex-end items-center justify-between">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  attr(:for, :any, required: true, doc: "the datastructure for the form")
  attr(:as, :any, default: nil, doc: "the server side parameter to collect all input under")

  attr(:rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"
  )

  slot(:inner_block, required: true)
  slot(:actions, doc: "the slot for form actions, such as a submit button")

  def create_project_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="flex flex-col gap-[8px] space-y-8 bg-white">
        <%= render_slot(@inner_block, f) %>

        <div :for={action <- @actions} class="mt-2 flex flex-end items-center justify-between">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  attr(:repo, :any, required: true)
  attr(:key, :string, required: true)

  def repository_row(assigns) do
    ~H"""
    <div
      key={@key}
      id={@key}
      class="flex flex-row justify-between bg-secondary p-2 m-2  border border-solid rounded-md border-primary"
    >
      <div>
        <h1><%= @repo.name %></h1>(<%= @repo.full_name <> " | " <> @repo.html_url %>)
      </div>
      <div class="mt-2">
        <.color_button
          type="submit"
          class="primary"
          phx-click={
            CodejamWeb.CoreComponents.show_modal(@repo.name <> "-create-project-confirm-modal")
          }
        >
          Create Project
        </.color_button>
      </div>
    </div>
    <CodejamWeb.CoreComponents.modal id={@repo.name <> "-create-project-confirm-modal"}>
      <.create_project_form
        for={@repo.form}
        phx-change="validate_create_project"
        phx-submit="create_project"
      >
        <div class="flex flex-col p-2 m-2 bg-white">
          <CodejamWeb.CoreComponents.input
            field={@repo.form[@repo.name <> "_GITPOROJECTKEYSEP_" <> "name"]}
            label="Project Name"
          />
          <CodejamWeb.CoreComponents.input
            field={@repo.form[@repo.name <> "_GITPOROJECTKEYSEP_" <> "url"]}
            label="GitHub URL"
          />
          <CodejamWeb.CoreComponents.input
            field={@repo.form[@repo.name <> "_GITPOROJECTKEYSEP_" <> "default_branch"]}
            label="Branch"
          />
          <CodejamWeb.CoreComponents.input
            field={@repo.form[@repo.name <> "_GITPOROJECTKEYSEP_" <> "api_url"]}
            type="hidden"
          />
          <CodejamWeb.CoreComponents.input
            field={@repo.form[@repo.name <> "_GITPOROJECTKEYSEP_" <> "commits_url"]}
            type="hidden"
          />
          <CodejamWeb.CoreComponents.input
            field={@repo.form[@repo.name <> "_GITPOROJECTKEYSEP_" <> "organization_id"]}
            type="hidden"
          />
        </div>
        <:actions>
          <div class="flex flex-col p-2 m-2 bg-white">
            <CodejamWeb.LibraryComponents.color_button type="submit" class="primary">
              Create
            </CodejamWeb.LibraryComponents.color_button>
          </div>
        </:actions>
      </.create_project_form>
    </CodejamWeb.CoreComponents.modal>
    """
  end

  attr(:repos, :list, default: [])

  def repository_list(assigns) do
    assigns =
      with %{repos: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, repo_id: fn {id, _item} -> id end)
      end

    assigns =
      with %{repos: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, repo_item: fn {_id, item} -> item end)
      end

    ~H"""
    <div class="flex flex-col">
      <%= for repo <- @repos do %>
        <.repository_row key={@repo_id.(repo)} repo={@repo_item.(repo)} />
      <% end %>
    </div>
    """
  end

  attr :github_oauth_url, :string

  def github_oauth_button(assigns) do
    # http://localhost:4000/oauth/callback/github?code=code&state=state
    ~H"""
    <button class="btn btn-outline btn-primary" phx-click={JS.navigate(@github_oauth_url)}>
      Connect GitHub
    </button>
    """
  end
end
