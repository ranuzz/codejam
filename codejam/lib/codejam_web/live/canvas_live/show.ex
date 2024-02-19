defmodule CodejamWeb.CanvasLive.Show do
  use CodejamWeb, :live_view

  alias Phoenix.PubSub

  @notestopic "notes"
  def discussion_topic(discussion_id) do
    "discussion:#" <> discussion_id
  end

  @impl true
  def mount(
        %{"id" => organization_id, "discussion_id" => discussion_id},
        _session,
        socket
      ) do
    PubSub.subscribe(Codejam.PubSub, @notestopic)
    PubSub.subscribe(Codejam.PubSub, discussion_topic(discussion_id))

    current_user = socket.assigns.current_user

    CodejamWeb.Presence.track(
      self(),
      discussion_topic(discussion_id),
      current_user.id,
      %{
        email: current_user.email,
        user_id: current_user.email
      }
    )

    inodes = Codejam.Canvas.get_file_tree_by_parent(discussion_id, nil, organization_id)

    inodes =
      Codejam.Canvas.get_file_tree_by_parent(
        discussion_id,
        hd(inodes).id,
        organization_id
      )

    root_path_replacer = hd(inodes).path

    inodes =
      Codejam.Canvas.get_file_tree_by_parent(
        discussion_id,
        hd(inodes).id,
        organization_id
      )

    membership =
      Codejam.Accounts.Membership.get_membership(socket.assigns.current_user.id, organization_id)

    current_notes = Codejam.Canvas.get_discussion_notes(discussion_id)

    socket =
      socket
      |> assign(:current_notes, current_notes)
      |> assign(:current_inode, "")
      |> assign(:root_file, inodes)
      |> assign(:root_path_replacer, root_path_replacer <> "/")
      |> assign(:file_content, "")
      |> assign(:parsed_file_content, [])
      |> assign(:open_files, [])
      |> assign(:membership_id, hd(membership).id)
      |> assign(:organization_id, organization_id)
      |> assign(:discussion_id, discussion_id)
      |> assign(:file_language, "js")
      |> assign(
        :note_form,
        to_form(%{
          "content" => "",
          "lines" => "",
          "inode_id" => 0,
          "membership_id" => hd(membership).id,
          "discussion_id" => discussion_id,
          "organization_id" => organization_id
        })
      )
      |> assign(:present_users, %{})
      |> handle_joins(CodejamWeb.Presence.list(discussion_topic(discussion_id)))
      |> assign(:full_file_tree, [])

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.discussion_canvas_layout>
      <.inode_tree_left_pane>
        <.file_tree_full rows={@root_file} root_path={@root_path_replacer} />
      </.inode_tree_left_pane>
      <.inode_content_container present_users={@present_users} current_user_id={@current_user.id}>
        <.source_code_viewer
          content={@file_content}
          parsed_content={@parsed_file_content}
          language={@file_language}
          form={@note_form}
          current_notes={
            assigns.current_notes |> Enum.filter(&(&1.inode_id == assigns.current_inode))
          }
          line_notes={
            assigns.current_notes
            |> Enum.filter(&(&1.inode_id == assigns.current_inode))
            |> Enum.map(fn n ->
              {String.split(n.lines, ":", limit: 1) |> List.first(),
               %{content: n.content, inode_id: n.inode_id}}
            end)
          }
        />
        <.file_list_viewer rows={@open_files} root_path={@root_path_replacer} />
      </.inode_content_container>
      <.discussion_right_toolbar></.discussion_right_toolbar>
    </.discussion_canvas_layout>
    """
  end

  @impl true
  def handle_event("add_note", params, socket) do
    if params["inode_id"] != "0" do
      {:ok, note} =
        Codejam.Canvas.create_note(
          params["content"],
          params["lines"],
          params["inode_id"],
          params["discussion_id"],
          params["membership_id"],
          params["organization_id"]
        )

      notify_parent({:saved, note})
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("tree_click", params, socket) do
    inode = Codejam.Canvas.get_inode(params["inode_id"])

    cond do
      inode.is_file ->
        {:ok, content} =
          Codejam.Objectstorage.S3.get_object(socket.assigns.organization_id, inode.path)

        file_language = List.last(String.split(inode.path, "."))
        IO.puts(content)
        IO.inspect(FileReader.add_line_numbers(String.split(content, "\n")))

        socket =
          socket
          |> assign(:current_inode, inode.id)
          |> assign(:file_content, content)
          |> assign(
            :parsed_file_content,
            FileReader.add_line_numbers(String.split(content, "\n"))
          )
          |> assign(:file_language, file_language)
          |> assign(:open_files, [])
          |> assign(
            :note_form,
            to_form(%{
              "content" => "",
              "lines" => "",
              "inode_id" => inode.id,
              "membership_id" => socket.assigns.membership_id,
              "discussion_id" => socket.assigns.discussion_id,
              "organization_id" => socket.assigns.organization_id
            })
          )

        {:noreply, socket}

      inode.is_dir ->
        inodes =
          Codejam.Canvas.get_file_tree_by_parent(
            socket.assigns.discussion_id,
            inode.id,
            socket.assigns.organization_id
          )

        socket =
          socket
          |> assign(:current_inode, inode.id)
          |> assign(:file_content, "")
          |> assign(:parsed_file_content, [])
          |> assign(:open_files, inodes)
          |> assign(:root_file, update_root_file(socket.assigns.root_file, inode.id))

        {:noreply, socket}

      true ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("file_list_click", params, socket) do
    inode = Codejam.Canvas.get_inode(params["inode_id"])

    cond do
      inode.is_file ->
        {:ok, content} = File.read(inode.path)
        parsed_file_content = FileReader.read_file_with_index_map(inode.path)

        file_language = List.last(String.split(inode.path, "."))

        socket =
          socket
          |> assign(:current_inode, inode.id)
          |> assign(:file_content, content)
          |> assign(:parsed_file_content, parsed_file_content)
          |> assign(:file_language, file_language)
          |> assign(:open_files, [])
          |> assign(
            :note_form,
            to_form(%{
              "content" => "",
              "lines" => "",
              "inode_id" => inode.id,
              "membership_id" => socket.assigns.membership_id,
              "discussion_id" => socket.assigns.discussion_id,
              "organization_id" => socket.assigns.organization_id
            })
          )

        {:noreply, socket}

      inode.is_dir ->
        inodes =
          Codejam.Canvas.get_file_tree_by_parent(
            socket.assigns.discussion_id,
            inode.id,
            socket.assigns.organization_id
          )

        socket =
          socket
          |> assign(:current_inode, inode.id)
          |> assign(:file_content, "")
          |> assign(:parsed_file_content, [])
          |> assign(:open_files, inodes)

        {:noreply, socket}

      true ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("add-note-editor", params, socket) do
    session_params = socket.assigns

    if session_params.current_inode != "0" do
      {:ok, note} =
        Codejam.Canvas.create_note(
          params["content"],
          params["line"] <> ":" <> params["line"],
          session_params.current_inode,
          session_params.discussion_id,
          session_params.membership_id,
          session_params.organization_id
        )

      notify_parent({:saved, note})
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({CodejamWeb.CanvasLive.Show, {:saved, note}}, socket) do
    current_notes = Codejam.Canvas.get_discussion_notes(note.discussion_id)

    socket =
      socket
      |> assign(:current_notes, current_notes)

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    {:noreply,
     socket
     |> handle_leaves(leaves)
     |> handle_joins(joins)}
  end

  defp notify_parent(msg) do
    PubSub.broadcast(Codejam.PubSub, @notestopic, {__MODULE__, msg})
    send(self(), {__MODULE__, msg})
  end

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

  defp load_children(inode, inode_id) do
    cond do
      inode.is_file ->
        inode

      inode.is_dir and inode.id == inode_id ->
        inode |> Codejam.Repo.preload(:children)

      inode.is_dir and inode.id != inode_id ->
        if Ecto.assoc_loaded?(inode.children) do
          Map.put(inode, :children, Enum.map(inode.children, &load_children(&1, inode_id)))
        else
          inode
        end

      true ->
        inode
    end
  end

  defp update_root_file(file_tree, inode_id) do
    x = Enum.map(file_tree, &load_children(&1, inode_id))
    x
  end
end
