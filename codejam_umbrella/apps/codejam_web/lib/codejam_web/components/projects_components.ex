defmodule CodejamWeb.ProjectsComponents do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  Grid of project to display all available projects
  """
  attr(:id, :string, required: true)
  attr(:rows, :list, required: true)
  attr(:gap, :string, default: "4")
  attr(:cols, :string, default: "2")

  def project_grid(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: fn {id, _item} -> id end)
      end

    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_item: fn {_id, item} -> item end)
      end

    ~H"""
    <div class={["grid", "grid-cols-" <> @cols, "gap-" <> @gap]}>
      <div
        :for={row <- @rows}
        id={@row_id && @row_id.(row)}
        class="card w-96 bg-primary text-primary-content"
      >
        <div class="card-body">
          <h2 class="card-title">
            <%= @row_item.(row).name %>
          </h2>
          <p><%= @row_item.(row).url %></p>
          <div class="card-actions justify-end">
            <button class="btn">Open</button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  List of project to display all available projects
  """
  attr(:id, :string, required: true)
  attr(:rows, :list, required: true)

  def project_list(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: fn {id, _item} -> id end)
      end

    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_item: fn {_id, item} -> item end)
      end

    ~H"""
    <div class="flex flex-col">
      <div
        :for={row <- @rows}
        id={@row_id && @row_id.(row)}
        class="flex flex-row justify-between gap-4 justify-space-between bg-secondary border border-solid rounded-md p-2 m-2"
      >
        <div>
          <h2 class="font-bold">
            <%= @row_item.(row).name %>
          </h2>
          <p><a href={@row_item.(row).url} target="_blank"><%= @row_item.(row).url %></a></p>
        </div>
        <div class="flex flex-end mt-2">
          <CodejamWeb.LibraryComponents.link_button href={"/project/" <> @row_item.(row).id}>
            Open
          </CodejamWeb.LibraryComponents.link_button>
          <button
            phx-click={
              JS.push("delete_project", value: %{project_id: @row_item.(row).id})
            }
            class="primary"
          >
            Delete
          </button>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  List of project to display all available projects
  """
  attr(:id, :string, required: true)
  attr(:rows, :list, required: true)

  def discussion_list(assigns) do
    # assigns =
    #   with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
    #     assign(assigns, row_id: fn {id, _item} -> id end)
    #   end

    # assigns =
    #   with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
    #     assign(assigns, row_item: fn {_id, item} -> item end)
    #   end

    ~H"""
    <div id="project-discussions" class="flex flex-col" phx-update="stream">
      <div
        :for={{row_id, row} <- @rows}
        id={row_id}
        class="flex flex-row justify-between gap-4 w-full justify-space-between bg-secondary border border-solid rounded-md p-2 m-2"
      >
        <div>
          <h2 class="font-bold">
            <%= row.title %>
          </h2>
        </div>
        <div class="flex flex-end mt-2">
          <CodejamWeb.LibraryComponents.link_button
            href={"/project/" <> row.project_id <> "/notebook/" <> row.id}
            class="primary"
          >
            Open
          </CodejamWeb.LibraryComponents.link_button>
          <button
            phx-click={
              JS.push("delete_notebook", value: %{notebook_id: row.id})
            }
            class="primary"
          >
            Delete
          </button>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Search form to fetch repositories that are not associated with any projects
  Contains a result section to show the list of repositories.
  Contains an empty state if there are no repos for the provided term
  """
  attr(:form, :any, required: true, doc: "the datastructure for the form")

  def github_repo_search(assigns) do
    ~H"""
    <CodejamWeb.LibraryComponents.search_box_form for={@form} phx-submit="search_repo">
      <CodejamWeb.CoreComponents.input field={@form[:query]} label="Search Repository" />
      <:actions>
        <button
          type="submit"
          class="text-white bg-violet-700 hover:bg-violet-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 focus:outline-none"
        >
          search
        </button>
      </:actions>
    </CodejamWeb.LibraryComponents.search_box_form>
    """
  end
end
