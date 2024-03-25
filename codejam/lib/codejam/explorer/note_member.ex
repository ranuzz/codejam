defmodule Codejam.Explorer.NoteMember do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "note_members" do
    field(:association, :string)
    belongs_to(:note, Codejam.Explorer.Note, type: :binary_id)
    belongs_to(:membership, Codejam.Accounts.Membership, type: :binary_id)

    belongs_to(:createdBy, Codejam.Accounts.Membership,
      foreign_key: :created_by_membership_id,
      type: :binary_id
    )

    belongs_to(:organization, Codejam.Accounts.Organization, type: :binary_id)
    timestamps(type: :utc_datetime)
  end
end
