defmodule Codejam.Canvas.Note do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "notes" do
    field(:lines, :string)
    field(:content, :string)

    belongs_to(:parent, Codejam.Canvas.Note, foreign_key: :parent_note_id, type: :binary_id)
    has_many(:children, Codejam.Canvas.Note, foreign_key: :parent_note_id)
    belongs_to(:discussion, Codejam.Canvas.Discussion, type: :binary_id)
    belongs_to(:organization, Codejam.Accounts.Organization, type: :binary_id)
    belongs_to(:membership, Codejam.Accounts.Membership, type: :binary_id)
    belongs_to(:inode, Codejam.Canvas.Inode, type: :binary_id)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:content, :lines])
    |> validate_required([:content, :lines])
  end
end
