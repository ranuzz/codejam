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
  attr(:rest, :global, include: ~w(disabled form name value))

  slot(:inner_block, required: true)

  def color_button(assigns) do
    ~H"""
    <button
      type={@type}
      class="text-white bg-gradient-to-br from-purple-600 to-blue-500 hover:bg-gradient-to-bl focus:ring-4 focus:outline-none focus:ring-blue-300 dark:focus:ring-blue-800 font-medium rounded-lg text-sm px-5 py-2.5 text-center me-2 mb-2"
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr(:type, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled form name value))
  attr(:icon, :string, default: "home")

  def icon_button(assigns) do
    ~H"""
    <button
      type={@type}
      class=""
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
      class="text-white bg-gradient-to-br from-purple-600 to-blue-500 hover:bg-gradient-to-bl focus:ring-4 focus:outline-none focus:ring-blue-300 dark:focus:ring-blue-800 font-medium rounded-lg text-sm px-5 py-2.5 text-center me-2 mb-2"
      href={@href}
    >
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  attr(:href, :string, default: "#")
  slot(:inner_block, required: true)

  def primary_link_button(assigns) do
    ~H"""
    <a
      href={@href}
      class="text-white bg-violet-700 hover:bg-violet-800 focus:ring-4 focus:ring-violet-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-violet-600 dark:hover:bg-violet-700 focus:outline-none dark:focus:ring-violet-800"
    >
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  attr(:icon, :string, default: "home")
  attr(:title, :string, default: "#")
  attr(:content, :string, default: "#")

  def feature_card(assigns) do
    ~H"""
    <div class="max-w-sm p-4 bg-white border border-violet-200 rounded-lg shadow">
      <span class="material-symbols-outlined">
        <%= @icon %>
      </span>
      <h5 class="mt-2 mb-2 text-xl font-semibold tracking-tight text-violet-900"><%= @title %></h5>
      <p class="text-sm text-gray-500">
        <%= @content %>
      </p>
    </div>
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
  slot(:right_actions, default: nil)

  def navbar(assigns) do
    ~H"""
    <nav class="bg-gradient-to-r from-violet-300 to-violet-500">
      <div class="mx-auto max-w-8xl px-2 sm:px-6 lg:px-8">
        <div class="relative flex h-16 items-center justify-between">
          <div class="flex flex-1 items-center justify-center sm:items-stretch sm:justify-start">
            <%= render_slot(@left_actions) %>
            <div class="flex flex-shrink-0 items-center mr-10">
              <a href="/"><img class="h-10 w-auto" src="/images/logo.png" alt="CodeJam Logo" /></a>
            </div>
          </div>
          <div class="absolute inset-y-0 right-0 flex items-center pr-2 sm:static sm:inset-auto sm:ml-6 sm:pr-0 space-x-2">
            <%= render_slot(@right_actions) %>
          </div>
        </div>
      </div>
    </nav>
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
    <.form :let={f} for={@for} as={@as} {@rest} class="w-8/12">
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

  attr(:repos, :list, default: [])

  def repository_list_new(assigns) do
    ~H"""
    <dl class="w-8/12 text-gray-900 divide-y divide-gray-200 dark:text-white dark:divide-gray-700">
      <%= for repo <- @repos do %>
        <div
          class="flex flex-col p-5 my-2 bg-secondary border border-solid rounded-md cursor-pointer"
          key={repo.id}
          phx-click={
            JS.push("select_repo", value: %{url: repo.html_url, name: repo.full_name, branch: repo.default_branch})
            |> JS.toggle(to: "#creating-project", in: "block fade-in", out: "hidden fade-out")
          }
        >
          <dt class="mb-1 text-gray-500 md:text-lg dark:text-gray-400"><%= repo.name %></dt>
          <dd class="text-lg font-semibold"><%= repo.full_name <> " | " <> repo.html_url %></dd>
        </div>
      <% end %>
    </dl>
    """
  end

  attr(:github_oauth_url, :string)

  def github_oauth_button(assigns) do
    # http://localhost:4000/oauth/callback/github?code=code&state=state
    ~H"""
    <button
      class="text-white bg-violet-700 hover:bg-violet-800 focus:ring-4 focus:ring-violet-300 font-medium rounded-lg text-sm px-5 py-2.5 focus:outline-none"
      phx-click={JS.navigate(@github_oauth_url)}
    >
      Connect GitHub
    </button>
    """
  end

  attr(:github_oauth_url, :string)

  def github_auth_oauth_button(assigns) do
    ~H"""
    <button
      type="button"
      class="text-xs text-white bg-[#24292F] hover:bg-[#24292F]/90 focus:ring-4 focus:outline-none focus:ring-[#24292F]/50 rounded-lg px-5 py-2.5 text-center inline-flex items-center me-2 mb-2"
      phx-click={JS.navigate(@github_oauth_url)}
    >
      <svg
        class="w-4 h-4 me-2"
        aria-hidden="true"
        xmlns="http://www.w3.org/2000/svg"
        fill="currentColor"
        viewBox="0 0 20 20"
      >
        <path
          fill-rule="evenodd"
          d="M10 .333A9.911 9.911 0 0 0 6.866 19.65c.5.092.678-.215.678-.477 0-.237-.01-1.017-.014-1.845-2.757.6-3.338-1.169-3.338-1.169a2.627 2.627 0 0 0-1.1-1.451c-.9-.615.07-.6.07-.6a2.084 2.084 0 0 1 1.518 1.021 2.11 2.11 0 0 0 2.884.823c.044-.503.268-.973.63-1.325-2.2-.25-4.516-1.1-4.516-4.9A3.832 3.832 0 0 1 4.7 7.068a3.56 3.56 0 0 1 .095-2.623s.832-.266 2.726 1.016a9.409 9.409 0 0 1 4.962 0c1.89-1.282 2.717-1.016 2.717-1.016.366.83.402 1.768.1 2.623a3.827 3.827 0 0 1 1.02 2.659c0 3.807-2.319 4.644-4.525 4.889a2.366 2.366 0 0 1 .673 1.834c0 1.326-.012 2.394-.012 2.72 0 .263.18.572.681.475A9.911 9.911 0 0 0 10 .333Z"
          clip-rule="evenodd"
        />
      </svg>
      Sign in with Github
    </button>
    """
  end

  def plus_svg(assigns) do
    ~H"""
    <svg
      class="w-3.5 h-3.5"
      aria-hidden="true"
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 18 18"
    >
      <path
        stroke="currentColor"
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M9 1v16M1 9h16"
      />
    </svg>
    """
  end
end
