defmodule Codejam.Explorer.Notebook do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "notebooks" do
    field(:title, :string)
    field(:kind, :string)
    belongs_to(:project, Codejam.Project, type: :binary_id)

    belongs_to(:createdBy, Codejam.Accounts.Membership,
      foreign_key: :created_by_membership_id,
      type: :binary_id
    )

    belongs_to(:organization, Codejam.Accounts.Organization, type: :binary_id)
    timestamps(type: :utc_datetime)
  end
end
