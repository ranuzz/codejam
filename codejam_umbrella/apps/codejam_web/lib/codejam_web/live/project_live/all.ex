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
      <CodejamWeb.ProjectsComponents.project_list id="org-projects" rows={@streams.projects} />
    </div>
    """
  end
end
