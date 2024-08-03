defmodule CodejamWeb.OrganizationLive.Home do
  use CodejamWeb, :live_view
  # Imports only from/2 of Ecto.Query
  import Ecto.Query, only: [from: 2]

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    integrations =
      Codejam.Repo.all(
        from(integtration in Codejam.Accounts.Integration,
          where: integtration.organization_id == ^id
        )
      )

    projects =
      Codejam.Repo.all(
        from(project in Codejam.Explorer.Project, where: project.organization_id == ^id)
      )

    socket =
      socket
      |> assign(:integrations, integrations)
      |> assign(:projects, projects)
      |> assign(:organization_id, id)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if length(@integrations) == 0 do %>
        <section class="bg-gray-50">
          <div class="flex flex-col items-center justify-center px-6 mx-auto md:h-screen lg:py-0">
            <h1 class="text-xl font-bold leading-tight tracking-tight text-violet-900">
              Please Connect Github
            </h1>
          </div>
        </section>
      <% else %>
        <div class="p-4 mx-40">
          <div class="p-4 border-2 border-gray-200 border-dashed rounded-lg ">
            <div class="grid grid-cols-3 gap-4 mb-4">
              <div
                phx-click="projects"
                class="flex items-center justify-center h-24 rounded bg-gray-50 cursor-pointer"
              >
                <p class="text-2xl text-gray-400">All Projects</p>
              </div>
              <div class="flex items-center justify-center h-24 rounded bg-gray-50 ">
                <p class="text-2xl text-gray-400 ">
                  <.plus_svg />
                </p>
              </div>
              <div
                phx-click="create_project"
                class="flex flex-column items-center justify-center h-24 rounded bg-gray-50 cursor-pointer"
              >
                <p class="text-2xl text-gray-400">Create New Project</p>
              </div>
            </div>
            <div class="flex items-center justify-center h-48 mb-4 rounded bg-gray-50 ">
              <p class="text-2xl text-gray-400 ">
                <.plus_svg />
              </p>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("create_project", _params, socket) do
    {:noreply,
     push_redirect(socket,
       to: "/organization/" <> socket.assigns.organization_id <> "/project/new"
     )}
  end

  @impl true
  def handle_event("projects", _params, socket) do
    {:noreply,
     push_redirect(socket,
       to: "/organization/" <> socket.assigns.organization_id <> "/projects"
     )}
  end
end
