defmodule CodejamWeb.ExplorerComponents do
  use Phoenix.Component
  use Phoenix.HTML
  alias Phoenix.LiveView.JS

  slot(:inner_block, required: true)

  def explorer_layout(assigns) do
    ~H"""
    <div class="flex flex row absolute left-0 w-full h-full overflow-hidden text-xs">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  slot(:inner_block, required: true)

  def explorer_file_tree(assigns) do
    ~H"""
    <aside class="z-40 min-w-[256px] w-fit h-screen">
      <div class="flex items-center font-bold uppercase h-8 bg-violet-100">
        <div class="m-1 p-1">Explorer</div>
      </div>
      <div class="h-full px-3 py-4 overflow-y-auto bg-violet-50">
        <%= render_slot(@inner_block) %>
      </div>
    </aside>
    """
  end

  attr(:present_users, :list, default: [])
  attr(:current_user_id, :integer, default: 0)

  def explorer_online_users(assigns) do
    ~H"""
    <div>
      <button
        id="dropdownDefaultButton"
        data-dropdown-toggle="online-user-dropdown"
        class="text-white bg-violet-700 rounded-lg text-sm px-5 py-2.5 text-center inline-flex items-center"
        type="button"
      >
        Online
      </button>
      <div
        id="online-user-dropdown"
        class="z-10 hidden bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700"
      >
        <ul
          class="py-2 text-sm text-gray-700 dark:text-gray-200"
          aria-labelledby="dropdownDefaultButton"
        >
          <%= for {user_id, user} <- @present_users do %>
            <%= if user_id == @current_user_id do %>
              <li key={user_id}>
                <div class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">
                  <%= user.email %> (me)
                </div>
              </li>
            <% else %>
              <li key={user_id}>
                <div class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">
                  <%= user.email %>
                </div>
              </li>
            <% end %>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  attr(:present_users, :list, default: [])
  attr(:current_user_id, :integer, default: 0)
  slot(:inner_block, required: true)

  def explorer_content_container(assigns) do
    ~H"""
    <div class="flex flex-col w-full overflow-scroll">
      <div class="border-bottom h-[36px]">
        <div class="flex flex-row items-center gap-2 mx-2 mt-1 font-bold uppercase">
          <div>File or Folder Content</div>
          <span
            phx-click={
              JS.push("show_notes")
              |> JS.toggle(to: "#note-sidebar", in: "block fade-in", out: "hidden fade-out")
            }
            class="cursor-pointer bg-violet-100 text-violet-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded dark:bg-gray-700 dark:text-violet-400 border border-violet-400"
          >
            notes
          </span>
          <%!-- <div class="mt-1">
            <.explorer_online_users present_users={@present_users} current_user_id={@current_user_id} />
          </div> --%>
        </div>
      </div>

      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:parsed_content, :list, default: [])

  def source_code_viewer_without_notes(assigns) do
    ~H"""
    <div class="p-2 m-2">
      <%= for {line_number, line } <- @parsed_content do %>
        <div class="flex flex-col gap-2" key={line_number}>
          <div class="flex flex-row gap-2">
            <div
              class="w-[32px] cursor-pointer"
              phx-line-number={line_number}
              phx-click={
                JS.push("add_note", value: %{line_number: line_number})
                |> JS.toggle(to: "#note-sidebar", in: "block fade-in", out: "hidden fade-out")
              }
            >
              <%= line_number %>
            </div>
            <div>
              <div class="highlight"><pre><%= raw(line.raw) %></pre></div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  attr(:note, :map, default: %{content: ""})

  def note(assigns) do
    ~H"""
    <div class="flex justify-between m-2 p-2 w-full">
      <button
        type="button"
        phx-click={JS.push("prev_note", value: %{note_id: @note.id, seq: @note.seq})}
        class="text-violet-700 hover:text-white border border-violet-700 hover:bg-violet-800 focus:ring-4 focus:outline-none focus:ring-violet-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center me-2 mb-2 dark:border-violet-400 dark:text-violet-400 dark:hover:text-white dark:hover:bg-violet-500 dark:focus:ring-violet-900"
      >
        Prev
      </button>
      <button
        type="button"
        phx-click={JS.push("next_note", value: %{note_id: @note.id, seq: @note.seq})}
        class="text-violet-700 hover:text-white border border-violet-700 hover:bg-violet-800 focus:ring-4 focus:outline-none focus:ring-violet-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center me-2 mb-2 dark:border-violet-400 dark:text-violet-400 dark:hover:text-white dark:hover:bg-violet-500 dark:focus:ring-violet-900"
      >
        Next
      </button>
    </div>
    <div
      phx-hook="NoteEditor"
      id={"inode-note-" <> @note.id}
      class="m-2 p-2 border border-solid rounded-md bg-violet-100 shadow-[-1px_0_5px_rgba(0,0,0,0.3)]"
      data-noteid={@note.id}
    >
      <div id="note-editor" class="bg-white">
        <%= raw(@note.content) %>
      </div>

      <div class="flex items-center justify-between w-full m-2">
        <button
          type="submit"
          phx-click={
            JS.dispatch("codejam:edit-editor",
              to: "#note-editor"
            )
          }
          class="text-white bg-gradient-to-r from-violet-500 via-violet-600 to-violet-700 hover:bg-gradient-to-br focus:ring-4 focus:outline-none focus:ring-violet-300 dark:focus:ring-violet-800 font-medium rounded-lg text-sm px-5 py-2.5 text-center me-2 mb-2"
        >
          Save Note
        </button>
        <button
          type="submit"
          phx-click={
            JS.push("delete_note", value: %{note_id: @note.id})
            |> JS.toggle(to: "#note-sidebar", in: "block fade-in", out: "hidden fade-out")
            }
          class="text-white bg-gradient-to-r from-violet-500 via-violet-600 to-violet-700 hover:bg-gradient-to-br focus:ring-4 focus:outline-none focus:ring-violet-300 dark:focus:ring-violet-800 font-medium rounded-lg text-sm px-5 py-2.5 text-center me-2 mb-2"
        >
          Delete
        </button>
      </div>
    </div>
    """
  end

  attr(:note, :map, default: %{content: ""})

  def note_card(assigns) do
    ~H"""
    <div class="block p-6 bg-violet-50 border border-violet-200 rounded-lg shadow hover:bg-violet-100">
      <p class="font-normal text-gray-700">
        <%= raw(@note.content) %>
      </p>
    </div>
    """
  end

  attr(:sidebar_mode, :string, default: "show_notes")
  attr(:line_number, :string, default: "0")
  attr(:notes, :list, default: [])
  attr(:note_id, :string, default: "")
  attr(:current_note, :map, default: %{})

  def note_sidebar(assigns) do
    ~H"""
    <div
      id="note-sidebar"
      class="hidden w-full h-full relative shadow-[-1px_0_5px_rgba(0,0,0,0.3)] bg-violet-50"
    >
      <%= case @sidebar_mode do %>
        <% "show_note" -> %>
          <.note note={@current_note} />
        <% "show_notes" -> %>
          <div class="m-2">
            <%= if Kernel.length(@notes) != 0 do %>
              <ul>
                <%= for note <- @notes do %>
                  <div
                    class="m-2 cursor-pointer"
                    phx-click={JS.push("show_note", value: %{note_id: note.id})}
                    class="cursor-pointer"
                  >
                    <.note_card note={note} />
                  </div>
                <% end %>
              </ul>
            <% else %>
              Not notes yet
            <% end %>
          </div>
        <% "add_note" -> %>
          <div
            phx-hook="NoteCreator"
            id={"inode-note-" <> @line_number}
            class="m-2 p-2 border border-solid rounded-md bg-violet-100 shadow-[-1px_0_5px_rgba(0,0,0,0.3)]"
            data-line={@line_number}
          >
            <div id="note-creator" class="bg-white">
              <p>Add a new Note</p>
            </div>

            <div class="flex items-center w-full m-2">
              <button
                type="submit"
                phx-click={
                  JS.dispatch("codejam:create-editor",
                    to: "#note-creator"
                  )
                  |> JS.toggle(to: "#note-sidebar", in: "block fade-in", out: "hidden fade-out")
                }
                class="text-white bg-gradient-to-r from-violet-500 via-violet-600 to-violet-700 hover:bg-gradient-to-br focus:ring-4 focus:outline-none focus:ring-violet-300 dark:focus:ring-violet-800 font-medium rounded-lg text-sm px-5 py-2.5 text-center me-2 mb-2"
              >
                Add Note
              </button>
            </div>
          </div>
        <% _ -> %>
          <%= @sidebar_mode %>
      <% end %>
    </div>
    """
  end
end
