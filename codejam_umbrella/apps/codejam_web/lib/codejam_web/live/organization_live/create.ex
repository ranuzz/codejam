defmodule CodejamWeb.OrganizationLive.Create do
  use CodejamWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:name_form, to_form(%{"name" => nil}))

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-4 mx-40">
      <.simple_form for={@name_form} id="name_form" phx-submit="create_org">
        <.input field={@name_form[:name]} type="text" label="Name" required />
        <:actions>
          <.button phx-disable-with="Creating...">Create Org</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def handle_event("create_org", params, socket) do
    user = socket.assigns.current_user

    {:ok, created_organization} =
      Codejam.Repo.insert(%Codejam.Accounts.Organization{name: params["name"]})

    Codejam.Repo.insert(%Codejam.Accounts.Membership{
      user_id: user.id,
      role: "user",
      organization_id: created_organization.id,
      active: true
    })

    {:noreply, redirect(socket, to: "/home")}
  end
end
