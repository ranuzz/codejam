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
      <h2 class="text-4xl font-extrabold dark:text-white pt-10 mx-2"><%= @project.name %></h2>
      <div class="flex flex-row gap-2 mt-2 mx-2 pb-10">
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
  def handle_event("delete_notebook", params, socket) do
    Codejam.Explorer.delete_notebook(
      socket.assigns.active_membership.organization_id,
      params["notebook_id"]
    )

    notify_parent({:removed, %{id: params["notebook_id"]}})

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_notebook_title", params, socket) do
    Codejam.Explorer.update_notebook(%{id: params["id"], title: params["title"]})

    {:noreply, socket}
  end

  @impl true
  def handle_info({CodejamWeb.ProjectLive.Show, {:saved, notbook}}, socket) do
    {:noreply, stream_insert(socket, :notbooks, notbook)}
  end

  @impl true
  def handle_info({CodejamWeb.ProjectLive.Show, {:removed, notbook}}, socket) do
    {:noreply, stream_delete(socket, :notbooks, notbook)}
  end

  defp notify_parent(msg) do
    PubSub.broadcast(Codejam.PubSub, @topic, {__MODULE__, msg})
    send(self(), {__MODULE__, msg})
  end
end
