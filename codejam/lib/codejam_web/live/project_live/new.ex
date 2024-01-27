defmodule CodejamWeb.ProjectLive.New do
  use CodejamWeb, :live_view

  @git_repo_key_sep "_GITPOROJECTKEYSEP_"

  @impl true
  def mount(%{"id" => organization_id}, _session, socket) do
    form_fields = %{"query" => "", "organization_id" => organization_id}

    socket =
      stream(socket, :repos, [])
      |> assign(:form, to_form(form_fields))

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.github_repo_search form={@form} />
    <.repository_list repos={@streams.repos} />
    """
  end

  # TODO: remove validation, we don't need it. keeping it here as sample code
  @impl true
  def handle_event("validate_search_repo_query", params, socket) do
    if String.length(params["query"]) === 0 do
      form = to_form(params, errors: [query: {"Can't be blank", []}])
      {:noreply, assign(socket, :form, form)}
    else
      {:noreply, assign(socket, form: to_form(params))}
    end
  end

  @impl true
  def handle_event("search_repo", params, socket) do
    {:ok, searched_repos} =
      Codejam.Github.Api.search_repo(params["organization_id"], params["query"])

    repo_items = searched_repos["items"]

    repos =
      Enum.map(repo_items, fn r ->
        %{
          :id => r["html_url"],
          :name => r["name"],
          :full_name => r["full_name"],
          :html_url => r["html_url"],
          :default_branch => r["default_branch"],
          :api_url => r["url"],
          :commits_url => r["commits_url"],
          :form =>
            to_form(%{
              (r["name"] <> @git_repo_key_sep <> "name") => r["name"],
              (r["name"] <> @git_repo_key_sep <> "url") => r["html_url"],
              (r["name"] <> @git_repo_key_sep <> "default_branch") => r["default_branch"],
              (r["name"] <> @git_repo_key_sep <> "api_url") => r["url"],
              (r["name"] <> @git_repo_key_sep <> "commits_url") => r["commits_url"],
              (r["name"] <> @git_repo_key_sep <> "organization_id") => params["organization_id"]
            })
        }
      end)

    IO.inspect(hd(repos))

    socket =
      stream(socket, :repos, repos)
      |> assign(:form, to_form(params))

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate_create_project", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end

  @impl true
  def handle_event("create_project", params, socket) do
    db_params =
      Enum.reduce(params, %{}, fn {key, value}, acc ->
        Map.put(
          acc,
          List.last(String.split(key, @git_repo_key_sep)),
          value
        )
      end)

    Codejam.Project.create_project(
      db_params["url"],
      db_params["name"],
      db_params["api_url"],
      db_params["commits_url"],
      db_params["default_branch"],
      db_params["organization_id"]
    )

    {:noreply, assign(socket, form: to_form(params))}
  end
end
