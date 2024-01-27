defmodule CodejamWeb.CanvasComponents do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  slot(:inner_block, required: true)

  def discussion_canvas_layout(assigns) do
    ~H"""
    <div class="flex flex row absolute top-[48px] left-0 w-full h-full overflow-hidden text-xs">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  slot(:inner_block, required: true)

  def inode_tree_left_pane(assigns) do
    ~H"""
    <div class="flex flex-col w-2/12">
      <div class="border-bottom">
        <div class="flex items-center m-1 p-1 font-bold uppercase h-[28px]">Explorer</div>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:present_users, :list, default: [])
  attr(:current_user_id, :integer, default: 0)
  slot(:inner_block, required: true)

  def inode_content_container(assigns) do
    ~H"""
    <div class="flex flex-col w-10/12 border border-solid border-1 border-gray overflow-scroll">
      <div class="border-bottom h-[36px]">
        <div class="flex flex-row items-center justify-center justify-between mx-2 font-bold uppercase">
          <div>File or Folder Content</div>
          <div class="mt-1">
            <.online_users present_users={@present_users} current_user_id={@current_user_id} />
            <CodejamWeb.LibraryComponents.icon_button
              type="button"
              class="primary"
              icon="add_circle"
              phx-click={CodejamWeb.CoreComponents.show_modal("add-file-note-modal")}
            />
            <CodejamWeb.LibraryComponents.icon_button
              type="button"
              class="primary"
              icon="library_books"
            />
          </div>
        </div>
      </div>

      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:for, :string, required: true)
  attr(:icon, :string, default: "home")
  attr(:tooltip, :string, default: "home")

  def drawer_icon_button(assigns) do
    ~H"""
    <div class="tooltip tooltip-left" data-tip={@tooltip}>
      <label
        for={@for}
        class={[
          "btn",
          "btn-outline",
          "btn-sm",
          "mx-[4px]",
          "mt-[4px]",
          "w-[48px]",
          "btn-primary"
        ]}
      >
        <span class="material-symbols-outlined">
          <%= @icon %>
        </span>
      </label>
    </div>
    """
  end

  slot(:inner_block, required: true)

  def discussion_right_toolbar(assigns) do
    ~H"""
    <div class="flex flex-col">
      <%= render_slot(@inner_block) %>
      <div class="drawer drawer-end">
        <input id="my-drawer-4" type="checkbox" class="drawer-toggle" />
        <div class="drawer-content">
          <!-- Page content here -->
          <.drawer_icon_button for="my-drawer-4" />
        </div>
        <div class="drawer-side">
          <label for="my-drawer-4" aria-label="close sidebar" class="drawer-overlay"></label>
          <ul class="menu p-4 w-80 min-h-full bg-base-200 text-base-content">
            <!-- Sidebar content here -->
            <li><a>Sidebar Item 1</a></li>
            <li><a>Sidebar Item 2</a></li>
          </ul>
        </div>
      </div>
    </div>
    """
  end

  attr(:rows, :list, required: true)
  attr(:root_path, :string, required: true)

  def file_list_viewer(assigns) do
    ~H"""
    <div :for={row <- @rows} id={"inode-id-" <> row.id} class="flex">
      <div
        class="flex flex-row"
        phx-click={
          JS.push("file_list_click",
            value: %{inode_id: row.id}
          )
        }
      >
        <div class="m-1 p-2 w-[540px] font-bold border border-solid rounded-md cursor-pointer">
          <%= String.replace(row.name, @root_path, "") %>
        </div>
      </div>
    </div>
    """
  end

  attr(:rows, :list, required: true)

  def notes_list(assigns) do
    ~H"""
    <div class="toast toast-end w-[400px] min-h-[200px]">
      <div :for={row <- @rows} id={"note-id-" <> row.id} class="alert alert-info">
        <div>
          <h2 class="font-bold">
            <%= row.content %>
          </h2>
        </div>
      </div>
    </div>
    """
  end

  attr(:content, :string, required: true)
  attr(:parsed_content, :list, default: [])
  attr(:language, :string, default: "js")
  attr(:form, :any, required: true, doc: "the datastructure for the form")
  attr(:current_notes, :list, default: [])
  attr(:line_notes, :list, default: [])

  def source_code_viewer(assigns) do
    ~H"""
    <div class="p-2 m-2">
      <CodejamWeb.CoreComponents.modal id="add-file-note-modal">
        <.create_note_form
          for={@form}
          phx-submit={
            JS.push("add_note")
            |> JS.exec("data-cancel", to: "#add-file-note-modal")
          }
        >
          <div class="flex flex-col p-2 m-2 bg-white">
            <CodejamWeb.CoreComponents.input type="textarea" field={@form["content"]} label="Note" />
            <CodejamWeb.CoreComponents.input field={@form["lines"]} label="Selected Lines" />
            <CodejamWeb.CoreComponents.input field={@form["inode_id"]} type="hidden" />
            <CodejamWeb.CoreComponents.input field={@form["discussion_id"]} type="hidden" />
            <CodejamWeb.CoreComponents.input field={@form["membership_id"]} type="hidden" />
            <CodejamWeb.CoreComponents.input field={@form["organization_id"]} type="hidden" />
          </div>
          <:actions>
            <div class="flex flex-col p-2 m-2 bg-white">
              <CodejamWeb.LibraryComponents.color_button type="submit" class="primary">
                Add
              </CodejamWeb.LibraryComponents.color_button>
            </div>
          </:actions>
        </.create_note_form>
      </CodejamWeb.CoreComponents.modal>
      <%= for {line_number, line } <- @parsed_content do %>
        <div class="flex flex-col gap-2" key={"file-content-line:#"<>line_number}>
          <div class="flex flex-row gap-2">
            <div
              class="w-[32px]"
              phx-click={
                JS.add_class("show", to: "#inode-note-" <> line_number, transition: "fade-in")
              }
            >
              <%= line_number %>
            </div>
            <div><%= line.raw %></div>
          </div>
          <%= for {_, d} <- @line_notes |> Enum.filter(fn {lines, _} -> lines == line_number end) do %>
            <div
              class="mx-[48px] p-1 border border-solid max-w-[720px]"
              key={"file-content-line:#"<>line_number<>d.content}
            >
              <%= d.content %>
            </div>
          <% end %>
          <div
            phx-hook="NoteEditor"
            id={"inode-note-" <>line_number}
            class="line-note-text-editor m-2 p-2 border border-solid max-w-[720px]"
            data-line={line_number}
          >
            <div id={"inode-note-" <>line_number <>"-editor"}>
              <p>Adding a note about</p>
              <pre><%= line.raw %></pre>
              <p><br /></p>
            </div>
            <div>
              <button
                type="submit"
                phx-click={
                  JS.dispatch("codejam:save-editor-" <> line_number,
                    to: "#inode-note-" <> line_number <> "-editor"
                  )
                }
              >
                Add Note
              </button>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    <%!-- <.notes_list rows={@current_notes} /> --%>
    """
  end

  attr(:for, :any, required: true, doc: "the datastructure for the form")
  attr(:as, :any, default: nil, doc: "the server side parameter to collect all input under")

  attr(:rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"
  )

  slot(:inner_block, required: true)
  slot(:actions, doc: "the slot for form actions, such as a submit button")

  def create_note_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="flex flex-col gap-[8px] space-y-8 bg-white">
        <%= render_slot(@inner_block, f) %>

        <div :for={action <- @actions} class="mt-2 flex flex-end items-center justify-between">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  attr(:present_users, :list, default: [])
  attr(:current_user_id, :integer, default: 0)

  def online_users(assigns) do
    ~H"""
    <div class="dropdown dropdown-hover dropdown-left">
      <CodejamWeb.LibraryComponents.icon_button
        tabindex="0"
        role="button"
        type="button"
        class="primary"
        icon="group"
      />
      <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-52">
        <%= for {user_id, user} <- @present_users do %>
          <%= if user_id == @current_user_id do %>
            <li key={user_id}><%= user.email %> (me)</li>
          <% else %>
            <li key={user_id}><%= user.email %></li>
          <% end %>
        <% end %>
      </ul>
    </div>
    """
  end

  attr(:file_row, :any, required: true)
  attr(:root_path, :string, required: true)

  def file_tree_file_row(assigns) do
    ~H"""
    <li>
      <a phx-click={
        JS.push("tree_click",
          value: %{inode_id: @file_row.id}
        )
      }>
        <span class="material-symbols-outlined">
          description
        </span>
        <%= String.replace(@file_row.name, @root_path, "") %>
      </a>
    </li>
    """
  end

  attr(:folder_row, :any, required: true)
  attr(:children_row, :list, default: [])
  attr(:root_path, :string, required: true)

  def file_tree_folder_row(assigns) do
    ~H"""
    <li>
      <details open>
        <summary phx-click={
          JS.push("tree_click",
            value: %{inode_id: @folder_row.id}
          )
        }>
          <span class="material-symbols-outlined">
            folder
          </span>
          <%= String.replace(@folder_row.name, @root_path, "") %>
        </summary>
        <.file_tree_partial rows={@children_row} root_path={@root_path} />
      </details>
    </li>
    """
  end

  attr(:rows, :list, default: [])
  attr(:root_path, :string, required: true)

  def file_tree_partial(assigns) do
    ~H"""
    <%= if Ecto.assoc_loaded?(@rows) do %>
      <ul>
        <%= for row <- @rows do %>
          <%= if row.is_file do %>
            <.file_tree_file_row file_row={row} root_path={@root_path} />
          <% else %>
            <.file_tree_folder_row
              folder_row={row}
              root_path={@root_path}
              children_row={row.children}
            />
          <% end %>
        <% end %>
      </ul>
    <% end %>
    """
  end

  attr(:rows, :list, default: [])
  attr(:root_path, :string, required: true)

  def file_tree_full(assigns) do
    ~H"""
    <div>
      <ul class="menu menu-xs max-w-xs w-full">
        <%= for row <- @rows do %>
          <%= if row.is_file do %>
            <.file_tree_file_row file_row={row} root_path={@root_path} />
          <% else %>
            <.file_tree_folder_row
              folder_row={row}
              root_path={@root_path}
              children_row={row.children}
            />
          <% end %>
        <% end %>
      </ul>
    </div>
    """
  end
end
