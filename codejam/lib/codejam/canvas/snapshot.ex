defmodule Codejam.Canvas.Snapshot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "snapshots" do
    field(:branch, :string)
    field(:commit_hash, :string)
    field(:storage_path, :string)

    belongs_to(:organization, Codejam.Accounts.Organization, type: :binary_id)
    belongs_to(:project, Codejam.Project, type: :binary_id)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:branch, :commit_hash, :storage_path])
    |> validate_required([:branch, :commit_hash, :storage_path])
  end
end
