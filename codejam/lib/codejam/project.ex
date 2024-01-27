defmodule Codejam.Project do
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
    belongs_to(:integration, Codejam.Integration, type: :binary_id)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:url, :name])
    |> validate_required([:url, :name])
  end

  def create_project(url, name, api_url, commits_url, default_branch, organization_id) do
    case is_binary(organization_id) do
      false ->
        integration = Codejam.Integration.get_first_integration(organization_id)

        add_project(
          url,
          name,
          api_url,
          commits_url,
          default_branch,
          integration.id,
          organization_id
        )

      true ->
        integration = Codejam.Integration.get_first_integration(organization_id)

        add_project(
          url,
          name,
          api_url,
          commits_url,
          default_branch,
          integration.id,
          organization_id
        )
    end
  end

  def add_project(
        url,
        name,
        api_url,
        commits_url,
        default_branch,
        integration_id,
        organization_id
      ) do
    {:ok, created_project} =
      Codejam.Repo.insert(%Codejam.Project{
        url: url,
        name: name,
        api_url: api_url,
        commits_url: commits_url,
        default_branch: default_branch,
        integration_id: integration_id,
        organization_id: organization_id
      })

    {:ok, latest_commits_hash_sha} =
      Codejam.Github.Api.get_repo_branch_commits(organization_id, commits_url, default_branch)

    {:ok, created_snapshot} =
      Codejam.Repo.insert(%Codejam.Canvas.Snapshot{
        branch: default_branch,
        commit_hash: latest_commits_hash_sha,
        storage_path: "LOCAL",
        project_id: created_project.id,
        organization_id: organization_id
      })

    Codejam.Github.Api.download_repo(
      api_url,
      default_branch,
      created_snapshot.id,
      latest_commits_hash_sha,
      organization_id
    )
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

  def get_all_discussions(organization_id, project_id) do
    query =
      from d in Codejam.Canvas.Discussion,
        join: s in assoc(d, :snapshot),
        join: p in assoc(s, :project),
        where: p.id == ^project_id and p.organization_id == ^organization_id

    Codejam.Repo.all(query)
  end

  def create_discussion(organization_id, project_id) do
    snapshots =
      Codejam.Repo.all(
        from s in Codejam.Canvas.Snapshot,
          where: s.organization_id == ^organization_id and s.project_id == ^project_id
      )

    snapshot_id = hd(snapshots).id

    Codejam.Repo.insert(%Codejam.Canvas.Discussion{
      title: "new discussion",
      snapshot_id: snapshot_id,
      organization_id: organization_id
    })
  end
end
