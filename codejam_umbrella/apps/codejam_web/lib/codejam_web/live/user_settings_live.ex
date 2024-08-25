defmodule CodejamWeb.UserSettingsLive do
  use CodejamWeb, :live_view

  alias Codejam.Accounts

  import Ecto.Query, only: [from: 2]

  def render(assigns) do
    ~H"""
    <div class="flex flex-row mx-40 py-20">
      <div class="w-4/12">
        <div class="border border-violet-900 rounded-lg m-2 p-2 bg-violet-50 mr-20 cursor-pointer">
          <ul class="max-w-md space-y-1 list-inside">
            <li class="flex items-center">
              <span class="material-symbols-outlined">
                badge
              </span>
              <a phx-value-tab="name" phx-click="change_tab">
                Change Name
              </a>
            </li>
            <li class="flex items-center">
              <span class="material-symbols-outlined">
                account_box
              </span>
              <a phx-value-tab="avatar" phx-click="change_tab">
                Change Avatar
              </a>
            </li>
            <li class="flex items-center">
              <span class="material-symbols-outlined">
                alternate_email
              </span>
              <a phx-value-tab="email" phx-click="change_tab">
                Change Email
              </a>
            </li>
            <li class="flex items-center">
              <span class="material-symbols-outlined">
                password
              </span>
              <a phx-value-tab="password" phx-click="change_tab">
                Change Password
              </a>
            </li>
            <li class="flex items-center">
              <span class="material-symbols-outlined">
                code
              </span>
              <a phx-value-tab="github" phx-click="change_tab">
                GitHub
              </a>
            </li>
            <li class="flex items-center">
              <span class="material-symbols-outlined">
                person_add
              </span>
              <a phx-value-tab="invite" phx-click="change_tab">
                Invite Member
              </a>
            </li>
          </ul>
        </div>
      </div>
      <div class="w-8/12">
        <%= case @tab do %>
          <% "name" -> %>
            <div class="-mt-[48px]">
              <.simple_form for={@name_form} id="name_form" phx-submit="update_name">
                <.input field={@name_form[:name]} type="text" label="Name" required />
                <:actions>
                  <.button phx-disable-with="Changing...">Change Name</.button>
                </:actions>
              </.simple_form>
            </div>
          <% "avatar" -> %>
            <div class="mt-[48px]">
              <%!-- <.simple_form for={@avatar_form} id="avatar_form" phx-submit="update_avatar" multipart>
                <.input field={@avatar_form[:avatar]} type="file" label="Avatar" />
                <:actions>
                  <.button>Change Avatar</.button>
                </:actions>
              </.simple_form> --%>
              <form id="upload-form" phx-submit="update_avatar" phx-change="validate_avatar">
                <.live_file_input upload={@uploads.avatar} />
                <button type="submit">Upload</button>
              </form>

              <%!-- use phx-drop-target with the upload ref to enable file drag and drop --%>
              <section phx-drop-target={@uploads.avatar.ref}>
                <%!-- render each avatar entry --%>
                <%= for entry <- @uploads.avatar.entries do %>
                  <article class="upload-entry">
                    <figure>
                      <.live_img_preview entry={entry} />
                      <figcaption><%= entry.client_name %></figcaption>
                    </figure>

                    <%!-- entry.progress will update automatically for in-flight entries --%>
                    <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>

                    <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
                    <button
                      type="button"
                      phx-click="cancel_upload_avatar"
                      phx-value-ref={entry.ref}
                      aria-label="cancel"
                    >
                      &times;
                    </button>

                    <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
                    <%= for err <- upload_errors(@uploads.avatar, entry) do %>
                      <p class="alert alert-danger"><%= error_to_string(err) %></p>
                    <% end %>
                  </article>
                <% end %>

                <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
                <%= for err <- upload_errors(@uploads.avatar) do %>
                  <p class="alert alert-danger"><%= error_to_string(err) %></p>
                <% end %>
              </section>
            </div>
          <% "password" -> %>
            <div class="-mt-[48px]">
              <.simple_form
                for={@password_form}
                id="password_form"
                action={~p"/users/log_in?_action=password_updated"}
                method="post"
                phx-change="validate_password"
                phx-submit="update_password"
                phx-trigger-action={@trigger_submit}
              >
                <.input
                  field={@password_form[:email]}
                  type="hidden"
                  id="hidden_user_email"
                  value={@current_email}
                />
                <.input
                  field={@password_form[:password]}
                  type="password"
                  label="New password"
                  required
                />
                <.input
                  field={@password_form[:password_confirmation]}
                  type="password"
                  label="Confirm new password"
                />
                <.input
                  field={@password_form[:current_password]}
                  name="current_password"
                  type="password"
                  label="Current password"
                  id="current_password_for_password"
                  value={@current_password}
                  required
                />
                <:actions>
                  <.button phx-disable-with="Changing...">Change Password</.button>
                </:actions>
              </.simple_form>
            </div>
          <% "email" -> %>
            <div class="-mt-[48px]">
              <.simple_form
                for={@email_form}
                id="email_form"
                phx-submit="update_email"
                phx-change="validate_email"
              >
                <.input field={@email_form[:email]} type="email" label="Email" required />
                <.input
                  field={@email_form[:current_password]}
                  name="current_password"
                  id="current_password_for_email"
                  type="password"
                  label="Current password"
                  value={@email_form_current_password}
                  required
                />
                <:actions>
                  <.button phx-disable-with="Changing...">Change Email</.button>
                </:actions>
              </.simple_form>
            </div>
          <% "github" -> %>
            <%= if @is_github_connected do %>
              <div>
                <span class="material-symbols-outlined">
                  check_circle
                </span>
                <span>GitHub is Connected!</span>
              </div>
            <% else %>
              <.github_oauth_button github_oauth_url={@oauth_url} />
            <% end %>
          <% "invite" -> %>
            <div class="-mt-[48px]">
              <.simple_form for={@invite_form} id="invite_form" phx-submit="invite_member">
                <.input field={@invite_form[:email]} type="email" label="Email" required />
                <:actions>
                  <.button phx-disable-with="Inviting...">Invite Member</.button>
                </:actions>
              </.simple_form>
            </div>
          <% _ -> %>
            <div>Choose a tab</div>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    name_changeset = Accounts.change_user_name(user)
    avatar_changeset = Accounts.change_user_avatar(user)

    integrations =
      Codejam.Repo.all(
        from(integtration in Codejam.Accounts.Integration,
          where: integtration.organization_id == ^socket.assigns.active_membership.organization_id
        )
      )

    is_github_connected = Kernel.length(integrations) !== 0

    socket =
      socket
      |> assign(:tab, "email")
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:name_form, to_form(name_changeset))
      |> assign(:avatar_form, to_form(avatar_changeset))
      |> assign(:trigger_submit, false)
      |> assign(
        :oauth_url,
        Codejam.Github.get_authorization_url(socket.assigns.active_membership.organization_id)
      )
      |> assign(:is_github_connected, is_github_connected)
      |> assign(:uploaded_files, [])
      |> assign(:invite_form, to_form(%{"email" => nil}))
      |> assign(:organization_id, socket.assigns.active_membership.organization_id)
      |> allow_upload(:avatar, accept: ~w(.jpg .jpeg), max_entries: 1)

    {:ok, socket}
  end

  def handle_event("update_name", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_name(user, user_params) do
      {:ok, _applied_user} ->
        {:noreply, socket |> put_flash(:info, "Name updated")}

      {:error, changeset} ->
        {:noreply, assign(socket, :name_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("invite_member", params, socket) do
    Accounts.invite_member(params["email"], socket.assigns.organization_id)
    {:noreply, socket}
  end

  def handle_event("validate_avatar", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel_upload_avatar", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  def handle_event("update_avatar", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        {:ok, binary_data} = File.read(path)
        base64_image_data = Base.encode64(binary_data)

        Accounts.update_user_avatar(socket.assigns.current_user, %{"avatar" => base64_image_data})
        {:ok, "/"}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, _applied_user} ->
        # TODO: fix this
        # Accounts.deliver_user_update_email_instructions(
        #   applied_user,
        #   user.email,
        #   &url(~p"/users/settings/confirm_email/#{&1}")
        # )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("change_tab", params, socket) do
    socket =
      socket
      |> assign(:tab, params["tab"])

    {:noreply, socket}
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  def error_to_string(:too_many_files), do: "You have selected too many files"
end
