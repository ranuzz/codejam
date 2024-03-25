defmodule Codejam.Explorer.Project do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  import Ecto.Query, only: [from: 2]

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "projects" do
    field(:url, :string)
    field(:name, :string)
    field(:api_url, :string)
    field(:commits_url, :string)
    field(:default_branch, :string)

    belongs_to(:organization, Codejam.Accounts.Organization, type: :binary_id)
    belongs_to(:integration, Codejam.Integrations.Integration, type: :binary_id)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:url, :name])
    |> validate_required([:url, :name])
  end

  def list_project(organization_id) do
    Codejam.Repo.all(
      from p in Codejam.Project,
        where: p.organization_id == ^organization_id
    )
  end

  def list_snapshots(organization_id, project_id) do
    Codejam.Repo.all(
      from s in Codejam.Canvas.Snapshot,
        where: s.organization_id == ^organization_id and s.project_id == ^project_id
    )
  end

  def get_project_info(project_id) do
    Codejam.Repo.get(Codejam.Project, project_id)
  end
end
