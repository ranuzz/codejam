defmodule CodejamWeb.OrganizationLive.Home do
  use CodejamWeb, :live_view
  # Imports only from/2 of Ecto.Query
  import Ecto.Query, only: [from: 2]

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    integrations =
      Codejam.Repo.all(
        from integtration in Codejam.Integrations.Integration,
          where: integtration.organization_id == ^id
      )

    projects =
      Codejam.Repo.all(
        from project in Codejam.Explorer.Project, where: project.organization_id == ^id
      )

    socket =
      socket
      |> assign(:integrations, integrations)
      |> assign(:projects, projects)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if length(@integrations) == 0 do %>
        <p>Please Connect Github</p>
      <% end %>
    </div>
    """
  end
end
