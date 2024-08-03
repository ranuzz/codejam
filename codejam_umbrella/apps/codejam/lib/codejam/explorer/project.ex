defmodule Codejam.Explorer.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "projects" do
    field(:url, :string)
    field(:name, :string)
    field(:branch, :string)

    belongs_to(:createdBy, Codejam.Accounts.Membership,
      foreign_key: :created_by_membership_id,
      type: :binary_id
    )

    belongs_to(:organization, Codejam.Accounts.Organization, type: :binary_id)
    timestamps(type: :utc_datetime)
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:url, :name, :branch, :organization_id, :created_by_membership_id])
    |> validate_required([:url, :name, :branch, :organization_id])
    |> foreign_key_constraint(:created_by_membership_id)
    |> foreign_key_constraint(:organization_id)
  end
end
