defmodule Codejam.Explorer.Note do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "notes" do
    field(:lines, :string)
    field(:content, :string)
    field(:kind, :string)
    field(:seq, :integer)
    belongs_to(:gitObject, Codejam.Explorer.GitObject, type: :binary_id)
    belongs_to(:notebook, Codejam.Explorer.Notebook, type: :binary_id)

    belongs_to(:createdBy, Codejam.Accounts.Membership,
      foreign_key: :created_by_membership_id,
      type: :binary_id
    )

    belongs_to(:organization, Codejam.Accounts.Organization, type: :binary_id)
    timestamps(type: :utc_datetime)
  end
end
