defmodule CodejamWeb.ProjectLive.New do
  use CodejamWeb, :live_view
  alias Codejam.Explorer

  @impl true
  def mount(_params, _session, socket) do
    form_fields = %{"query" => ""}

    socket =
      socket
      |> assign(:form, to_form(form_fields))
      |> assign(:searched_repos, [])
      |> assign(:organization_id, socket.assigns.active_membership.organization_id)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-40 py-10 w-full">
      <h2 class="mb-2 text-lg font-semibold">Create Project</h2>
      <div class="flex flex-col py-10">
        <.github_repo_search form={@form} />
        <.repository_list_new repos={@searched_repos} />
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("search_repo", params, socket) do
    result = Codejam.Github.search_repo(socket.assigns.organization_id, params["query"])

    searched_repos =
      Enum.map(result["items"], fn repo ->
        %{
          :id => repo["html_url"],
          :name => repo["name"],
          :full_name => repo["full_name"],
          :html_url => repo["html_url"],
          :default_branch => repo["default_branch"],
          :api_url => repo["url"],
          :commits_url => repo["commits_url"]
        }
      end)

    socket =
      socket
      |> assign(:searched_repos, searched_repos)

    {:noreply, socket}
  end

  def handle_event("select_repo", params, socket) do
    if !Explorer.project_exist?(params["name"], socket.assigns.organization_id) do
      Explorer.create_project(Map.put(params, "organization_id", socket.assigns.organization_id))
    end

    {:noreply, socket}
  end
end
