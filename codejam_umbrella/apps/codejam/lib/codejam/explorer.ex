defmodule Codejam.Explorer do
  @moduledoc """
  Explorer context that covers all objects related to code explorer
  """

  require Logger

  import Ecto.Query, only: [from: 2]

  alias Codejam.Repo
  alias Codejam.Explorer.{Project, GitObject, Notebook, Note}

  ## Project Object

  @doc """
  Create a project object.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs) do
    {:ok, project} =
      %Project{}
      |> Project.changeset(attrs)
      |> Repo.insert()

    Task.Supervisor.start_child(Codejam.TaskSupervisor, fn ->
      Codejam.SyncRepo.sync_repo(project)
    end)
  end

  def project_exist?(name, organization_id) do
    result = Repo.get_by(Project, name: name, organization_id: organization_id)
    !is_nil(result)
  end

  def get_project(id) do
    Repo.get(Project, id)
  end

  def list_project(organization_id) do
    Repo.all(from(Project, where: [organization_id: ^organization_id]))
  end

  def delete_project(organization_id, project_id) do
    from(project in Project,
      where: [id: ^project_id, organization_id: ^organization_id]
    )
    |> Repo.delete_all()
  end

  ## GitObjects Object

  @doc """
  """
  def create_git_object(attr) do
    %GitObject{}
    |> GitObject.changeset(attr)
    |> Repo.insert()
  end

  def git_object_exist?(sha, project_id) do
    result = Repo.get_by(GitObject, sha: sha, project_id: project_id)
    !is_nil(result)
  end

  def most_recent_commit(project_id) do
    Repo.one(
      from(g in GitObject,
        where: [project_id: ^project_id, object_type: "commit"],
        order_by: [desc: g.inserted_at],
        limit: 1
      )
    )
  end

  def get_git_object(sha, project_id) do
    Repo.get_by(GitObject, sha: sha, project_id: project_id)
  end

  def get_git_object(id) do
    Repo.get(GitObject, id)
  end

  def get_git_objects(sha_list, project_id) do
    query = from(row in GitObject, where: row.sha in ^sha_list and row.project_id == ^project_id)
    rows = Repo.all(query)
    rows |> Enum.map(&Map.put(&1, :children, []))
  end

  ## Notebook Object

  def create_notebook(attr) do
    %Notebook{}
    |> Notebook.changeset(attr)
    |> Repo.insert()
  end

  def list_notebook(organization_id, project_id) do
    Repo.all(from(Notebook, where: [organization_id: ^organization_id, project_id: ^project_id]))
  end

  def delete_notebook(organization_id, notebook_id) do
    from(notebook in Notebook,
      where: [id: ^notebook_id, organization_id: ^organization_id]
    )
    |> Repo.delete_all()
  end

  ## Note object

  def create_note(attr) do
    %Note{}
    |> Note.changeset(attr)
    |> Repo.insert()
  end

  def update_note(attr) do
    note = Repo.get!(Note, attr.id)
    note = Ecto.Changeset.change(note, content: attr.content)
    Repo.update(note)
  end

  def list_notes(organization_id, notebook_id, git_object_id) do
    Repo.all(
      from(Note,
        where: [
          organization_id: ^organization_id,
          notebook_id: ^notebook_id,
          git_object_id: ^git_object_id
        ]
      )
    )
  end

  def delete_note(note_id) do
    from(note in Note, where: note.id == ^note_id) |> Repo.delete_all()
  end

  def max_seq(notebook_id, organization_id) do
    query =
      from(n in Note,
        select: max(n.seq),
        where: [
          organization_id: ^organization_id,
          notebook_id: ^notebook_id
        ]
      )

    ms = Repo.one(query)

    if is_nil(ms) do
      0
    else
      ms
    end
  end

  def next_note(notebook_id, organization_id, seq) do
    query =
      from(n in Note,
        where:
          n.organization_id == ^organization_id and
            n.notebook_id == ^notebook_id and
            n.seq > ^seq,
        order_by: [asc: :seq],
        limit: 1
      )

    Repo.one(query)
  end

  def prev_note(notebook_id, organization_id, seq) do
    query =
      from(n in Note,
        where:
          n.organization_id == ^organization_id and
            n.notebook_id == ^notebook_id and
            n.seq < ^seq,
        order_by: [desc: :seq],
        limit: 1
      )

    Repo.one(query)
  end
end
