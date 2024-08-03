defmodule Codejam.Explorer.GitObject do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "git_objects" do
    field(:object_type, :string)
    field(:sha, :string)
    field(:tree, :string)
    field(:content, :string)
    field(:path, :string)

    belongs_to(:project, Codejam.Explorer.Project, type: :binary_id)

    belongs_to(:createdBy, Codejam.Accounts.Membership,
      foreign_key: :created_by_membership_id,
      type: :binary_id
    )

    belongs_to(:organization, Codejam.Accounts.Organization, type: :binary_id)
    timestamps(type: :utc_datetime)
  end

  def changeset(git_object, attrs) do
    git_object
    |> cast(attrs, [
      :sha,
      :tree,
      :content,
      :path,
      :project_id,
      :object_type,
      :created_by_membership_id,
      :organization_id
    ])
    |> validate_required([:sha, :object_type, :project_id, :organization_id])
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:created_by_membership_id)
    |> foreign_key_constraint(:organization_id)
  end
end
