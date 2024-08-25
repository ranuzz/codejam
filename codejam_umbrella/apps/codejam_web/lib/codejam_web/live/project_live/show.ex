defmodule CodejamWeb.ProjectLive.Show do
  use CodejamWeb, :live_view

  alias Phoenix.PubSub

  @topic "notebooks"

  def subscribe() do
    PubSub.subscribe(Codejam.PubSub, @topic)
  end

  def notify({:ok, message}, event) do
    PubSub.broadcast(Codejam.PubSub, @topic, {event, message})
  end

  @impl true
  def mount(%{"project_id" => project_id}, _session, socket) do
    subscribe()

    socket =
      socket
      |> stream(
        :notbooks,
        Codejam.Explorer.list_notebook(
          socket.assigns.active_membership.organization_id,
          project_id
        )
      )
      |> assign(:organization_id, socket.assigns.active_membership.organization_id)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-40 py-10">
      <h1 class="font-bold"><%= @project.name %></h1>
      <div class="flex flex-row gap-2 mt-2">
        <CodejamWeb.LibraryComponents.color_button
          type="button"
          class="primary"
          phx-click={
            JS.push("create_notebook",
              value: %{
                project_id: @project.id,
                organization_id: @organization_id,
                title: "Untitled Notebook",
                kind: "discussion"
              }
            )
          }
        >
          Create Notebook
        </CodejamWeb.LibraryComponents.color_button>
      </div>
      <.discussion_list id="project-notbook" rows={@streams.notbooks} />
    </div>
    """
  end

  @impl true
  def handle_params(%{"project_id" => project_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:project, Codejam.Explorer.get_project(project_id))}
  end

  @impl true
  def handle_event("create_notebook", params, socket) do
    {:ok, notebook} =
      Codejam.Explorer.create_notebook(params)

    notify_parent({:saved, notebook})

    {:noreply, socket}
  end

  @impl true
  def handle_event("open_notbook", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({CodejamWeb.ProjectLive.Show, {:saved, notbook}}, socket) do
    {:noreply, stream_insert(socket, :notbooks, notbook)}
  end

  defp notify_parent(msg) do
    PubSub.broadcast(Codejam.PubSub, @topic, {__MODULE__, msg})
    send(self(), {__MODULE__, msg})
  end
end
