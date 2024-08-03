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
    <.simple_form for={@name_form} id="name_form" phx-submit="update_name">
      <.input field={@name_form[:name]} type="text" label="Name" required />
      <:actions>
        <.button phx-disable-with="Changing...">Create Org</.button>
      </:actions>
    </.simple_form>
    """
  end

  @impl true
  def handle_event("update_name", params, socket) do
    user = socket.assigns.current_user

    {:ok, created_organization} =
      Codejam.Repo.insert(%Codejam.Accounts.Organization{name: params["name"]})

    Codejam.Repo.insert(%Codejam.Accounts.Membership{
      user_id: user.id,
      role: "user",
      organization_id: created_organization.id
    })

    {:noreply, socket}
  end
end
