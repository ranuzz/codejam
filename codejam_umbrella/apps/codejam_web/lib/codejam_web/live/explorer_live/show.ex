defmodule CodejamWeb.ExplorerLive.Show do
  use CodejamWeb, :live_view

  alias Phoenix.PubSub

  @notestopic "notes"
  def notbook_topic(notebook_id) do
    "notbook:#" <> notebook_id
  end

  @impl true
  def mount(
        %{"id" => organization_id, "project_id" => project_id, "notebook_id" => notebook_id},
        _session,
        socket
      ) do
    PubSub.subscribe(Codejam.PubSub, @notestopic)
    PubSub.subscribe(Codejam.PubSub, notbook_topic(notebook_id))

    current_user = socket.assigns.current_user

    CodejamWeb.Presence.track(
      self(),
      notbook_topic(notebook_id),
      current_user.id,
      %{
        email: current_user.email,
        user_id: current_user.email
      }
    )

    commit = Codejam.Explorer.most_recent_commit(project_id)
    root_tree = Codejam.Explorer.get_git_object(commit.tree, project_id)
    root_file = Codejam.Explorer.get_git_objects(String.split(root_tree.content, ","), project_id)

    membership =
      Codejam.Accounts.Membership.get_membership(socket.assigns.current_user.id, organization_id)

    socket =
      socket
      |> assign(:current_notes, [])
      |> assign(:current_git_object, nil)
      |> assign(:root_file, root_file)
      |> assign(:parsed_file_content, [])
      |> assign(:open_files, root_file)
      |> assign(:membership_id, hd(membership).id)
      |> assign(:organization_id, organization_id)
      |> assign(:notebook_id, notebook_id)
      |> assign(:project_id, project_id)
      |> assign(:commit, commit)
      |> assign(:present_users, %{})
      |> handle_joins(CodejamWeb.Presence.list(notbook_topic(notebook_id)))
      |> assign(:full_file_tree, [])
      |> assign(:sidebar_mode, "show_notes")
      |> assign(:add_note_line, "0")
      |> assign(:current_note_id, "")
      |> assign(:current_note, %{content: ""})

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.explorer_layout>
      <.explorer_file_tree>
        <.file_tree_full rows={@root_file} />
      </.explorer_file_tree>
      <.explorer_content_container present_users={@present_users} current_user_id={@current_user.id}>
        <.source_code_viewer_without_notes parsed_content={@parsed_file_content} />
        <.file_list_viewer rows={@open_files} />
      </.explorer_content_container>
      <.note_sidebar
        sidebar_mode={@sidebar_mode}
        line_number={@add_note_line}
        notes={@current_notes}
        note_id={@current_note_id}
        current_note={@current_note}
      />
    </.explorer_layout>
    """
  end

  @impl true
  def handle_event("add_note", params, socket) do
    # notify_parent({:saved, note})
    socket =
      socket
      |> assign(:sidebar_mode, "add_note")
      |> assign(:add_note_line, params["line_number"])

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_notes", _params, socket) do
    if not is_nil(socket.assigns.current_git_object) do
      socket =
        socket
        |> assign(
          :current_notes,
          Codejam.Explorer.list_notes(
            socket.assigns.organization_id,
            socket.assigns.notebook_id,
            socket.assigns.current_git_object
          )
        )

      socket = socket |> assign(:sidebar_mode, "show_notes")
      {:noreply, socket}
    else
      socket = socket |> assign(:sidebar_mode, "show_notes")
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("show_note", params, socket) do
    current_note =
      Enum.find(socket.assigns.current_notes, fn n -> n.id == params["note_id"] end)

    socket =
      socket
      |> assign(:sidebar_mode, "show_note")
      |> assign(:current_note_id, params["note_id"])
      |> assign(:current_note, current_note)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_note", params, socket) do
    Codejam.Explorer.delete_note(params["note_id"])
    {:noreply, socket}
  end

  @impl true
  def handle_event("prev_note", params, socket) do
    note =
      Codejam.Explorer.prev_note(
        socket.assigns.notebook_id,
        socket.assigns.organization_id,
        params["seq"]
      )

    move_note(note, socket)
  end

  @impl true
  def handle_event("next_note", params, socket) do
    note =
      Codejam.Explorer.next_note(
        socket.assigns.notebook_id,
        socket.assigns.organization_id,
        params["seq"]
      )

    move_note(note, socket)
  end

  @impl true
  def handle_event("tree_click", params, socket) do
    explorer_click(params["git_object_id"], socket)
  end

  @impl true
  def handle_event("file_list_click", params, socket) do
    explorer_click(params["git_object_id"], socket)
  end

  @impl true
  def handle_event("add-note-creator", params, socket) do
    max_seq = Codejam.Explorer.max_seq(socket.assigns.notebook_id, socket.assigns.organization_id)

    Codejam.Explorer.create_note(%{
      content: params["content"],
      lines: params["line"],
      git_object_id: socket.assigns.current_git_object,
      notebook_id: socket.assigns.notebook_id,
      organization_id: socket.assigns.organization_id,
      seq: max_seq + 1
    })

    # notify_parent({:saved, note})
    {:noreply, socket}
  end

  @impl true
  def handle_event("add-note-editor", params, socket) do
    Codejam.Explorer.update_note(%{
      id: params["noteid"],
      content: params["content"]
    })

    {:noreply, socket}
  end

  @impl true
  def handle_info({CodejamWeb.ExplorerLive.Show, {:saved, _note}}, socket) do
    # current_notes = Codejam.Canvas.get_notbook_notes(note.notebook_id)

    # socket =
    #   socket
    #   |> assign(:current_notes, current_notes)

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    {:noreply,
     socket
     |> handle_leaves(leaves)
     |> handle_joins(joins)}
  end

  # defp notify_parent(msg) do
  #   PubSub.broadcast(Codejam.PubSub, @notestopic, {__MODULE__, msg})
  #   send(self(), {__MODULE__, msg})
  # end

  defp handle_joins(socket, joins) do
    Enum.reduce(joins, socket, fn {user, %{metas: [meta | _]}}, socket ->
      assign(socket, :present_users, Map.put(socket.assigns.present_users, user, meta))
    end)
  end

  defp handle_leaves(socket, leaves) do
    Enum.reduce(leaves, socket, fn {user, _}, socket ->
      assign(socket, :present_users, Map.delete(socket.assigns.present_users, user))
    end)
  end

  defp load_children(git_object, git_object_id, project_id) do
    cond do
      git_object.object_type == "blob" ->
        git_object

      git_object.object_type == "tree" and git_object.id == git_object_id ->
        Map.put(
          git_object,
          :children,
          Codejam.Explorer.get_git_objects(String.split(git_object.content, ","), project_id)
        )

      git_object.object_type == "tree" and git_object.id != git_object_id ->
        Map.put(
          git_object,
          :children,
          Enum.map(git_object.children, &load_children(&1, git_object_id, project_id))
        )

      true ->
        git_object
    end
  end

  defp update_root_file(file_tree, git_object_id, project_id) do
    Enum.map(file_tree, &load_children(&1, git_object_id, project_id))
  end

  defp add_line_numbers(lines) do
    Stream.map(lines, & &1)
    |> Stream.with_index()
    |> Stream.map(fn {line, index} ->
      {Integer.to_string(index + 1), %{raw: line, notes: []}}
    end)
    |> Enum.to_list()
  end

  defp get_parsed_file_content(sha, project_id, organization_id) do
    content =
      Codejam.ObjectStore.read(
        sha,
        project_id,
        organization_id
      )

    process_content =
      String.replace(
        String.replace(content, "<div class=\"highlight\"><pre>", ""),
        "</pre></div>",
        ""
      )

    add_line_numbers(String.split(process_content, "\n"))
  end

  defp explorer_click(git_object_id, socket) do
    git_object = Codejam.Explorer.get_git_object(git_object_id)

    cond do
      git_object.object_type == "blob" ->
        parsed_file_content =
          get_parsed_file_content(
            git_object.sha,
            socket.assigns.project_id,
            socket.assigns.organization_id
          )

        socket =
          socket
          |> assign(:current_git_object, git_object.id)
          |> assign(
            :parsed_file_content,
            parsed_file_content
          )
          |> assign(:open_files, [])

        {:noreply, socket}

      git_object.object_type == "tree" ->
        tree_objects =
          Codejam.Explorer.get_git_objects(
            String.split(git_object.content, ","),
            socket.assigns.project_id
          )

        socket =
          socket
          |> assign(:current_git_object, git_object.id)
          |> assign(:parsed_file_content, [])
          |> assign(:open_files, tree_objects)
          |> assign(
            :root_file,
            update_root_file(socket.assigns.root_file, git_object.id, socket.assigns.project_id)
          )

        {:noreply, socket}

      true ->
        {:noreply, socket}
    end
  end

  defp move_note(note, socket) do
    if is_nil(note) do
      {:noreply, socket}
    else
      {_, socket} = explorer_click(note.git_object_id, socket)

      socket =
        socket
        |> assign(:sidebar_mode, "show_note")
        |> assign(:current_note_id, note.id)
        |> assign(:current_note, note)

      {:noreply, socket}
    end
  end
end
