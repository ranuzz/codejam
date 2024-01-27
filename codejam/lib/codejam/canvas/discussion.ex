defmodule Codejam.Canvas.Discussion do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "discussions" do
    field(:title, :string)

    belongs_to(:organization, Codejam.Accounts.Organization, type: :binary_id)
    belongs_to(:snapshot, Codejam.Canvas.Snapshot, type: :binary_id)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
