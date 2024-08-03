defmodule Codejam.Explorer.Note do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "notes" do
    field(:lines, :string)
    field(:content, :string)
    field(:kind, :string)
    field(:seq, :integer)
    belongs_to(:git_object, Codejam.Explorer.GitObject, type: :binary_id)
    belongs_to(:notebook, Codejam.Explorer.Notebook, type: :binary_id)

    belongs_to(:createdBy, Codejam.Accounts.Membership,
      foreign_key: :created_by_membership_id,
      type: :binary_id
    )

    belongs_to(:organization, Codejam.Accounts.Organization, type: :binary_id)
    timestamps(type: :utc_datetime)
  end

  def changeset(note, attrs) do
    note
    |> cast(attrs, [
      :content,
      :lines,
      :git_object_id,
      :kind,
      :seq,
      :notebook_id,
      :organization_id,
      :created_by_membership_id
    ])
    |> validate_required([:content, :lines, :git_object_id, :notebook_id, :organization_id])
    |> foreign_key_constraint(:created_by_membership_id)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:notebook_id)
    |> foreign_key_constraint(:git_object_id)
  end
end
