defmodule CodejamWeb.ProjectLive.All do
  use CodejamWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    projects =
      Enum.map(
        Codejam.Explorer.list_project(socket.assigns.active_membership.organization_id),
        fn p ->
          %{
            :id => p.id,
            :name => p.name,
            :url => p.url,
            :organization_id => socket.assigns.active_membership.organization_id
          }
        end
      )

    {:ok, stream(socket, :projects, projects)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-40 py-10">
      <h2 class="text-4xl font-extrabold dark:text-white py-10 mx-2">Projects</h2>
      <CodejamWeb.ProjectsComponents.project_list id="org-projects" rows={@streams.projects} />
    </div>
    """
  end

  @impl true
  def handle_event("delete_project", params, socket) do
    Codejam.Explorer.delete_project(
      socket.assigns.active_membership.organization_id,
      params["project_id"]
    )

    {:noreply, redirect(socket, to: "/projects")}
  end
end
