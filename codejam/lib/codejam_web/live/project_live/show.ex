defmodule CodejamWeb.ProjectLive.Show do
  use CodejamWeb, :live_view

  alias Phoenix.PubSub
  alias Codejam.Project

  @topic "discussions"

  def subscribe() do
    PubSub.subscribe(Codejam.PubSub, @topic)
  end

  def notify({:ok, message}, event) do
    PubSub.broadcast(Codejam.PubSub, @topic, {event, message})
  end

  @impl true
  def mount(%{"id" => id, "project_id" => project_id}, _session, socket) do
    subscribe()

    socket =
      socket
      |> stream(:discussions, Project.get_all_discussions(id, project_id))
      |> assign(:organization_id, id)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="font-bold"><%= @project.name %></h1>
    <div class="flex flex-row gap-2 mt-2">
      <CodejamWeb.LibraryComponents.color_button
        type="button"
        class="primary"
        phx-click={
          JS.push("create_discussion",
            value: %{project_id: @project.id, organization_id: @organization_id}
          )
        }
      >
        Create Discussion
      </CodejamWeb.LibraryComponents.color_button>
    </div>
    <.discussion_list id="project-discussion" rows={@streams.discussions} />
    """
  end

  @impl true
  def handle_params(%{"project_id" => project_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:project, Project.get_project_info(project_id))}
  end

  @impl true
  def handle_event("create_discussion", params, socket) do
    {:ok, discussion} =
      Codejam.Project.create_discussion(params["organization_id"], params["project_id"])

    notify_parent({:saved, discussion})

    {:noreply, socket}
  end

  @impl true
  def handle_event("open_discussion", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({CodejamWeb.ProjectLive.Show, {:saved, discussion}}, socket) do
    {:noreply, stream_insert(socket, :discussions, discussion)}
  end

  defp notify_parent(msg) do
    PubSub.broadcast(Codejam.PubSub, @topic, {__MODULE__, msg})
    send(self(), {__MODULE__, msg})
  end
end
