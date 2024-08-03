defmodule Codejam.Explorer.Notebook do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "notebooks" do
    field(:title, :string)
    field(:kind, :string)
    belongs_to(:project, Codejam.Explorer.Project, type: :binary_id)

    belongs_to(:createdBy, Codejam.Accounts.Membership,
      foreign_key: :created_by_membership_id,
      type: :binary_id
    )

    belongs_to(:organization, Codejam.Accounts.Organization, type: :binary_id)
    timestamps(type: :utc_datetime)
  end

  def changeset(notebook, attrs) do
    notebook
    |> cast(attrs, [:title, :kind, :project_id, :organization_id, :created_by_membership_id])
    |> validate_required([:title, :project_id, :organization_id])
    |> foreign_key_constraint(:created_by_membership_id)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
  end
end
