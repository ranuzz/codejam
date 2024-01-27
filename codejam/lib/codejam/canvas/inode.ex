defmodule Codejam.Canvas.Inode do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "inodes" do
    field(:path, :string)
    field(:name, :string)
    field(:is_file, :boolean)
    field(:is_dir, :boolean)

    belongs_to(:parent, Codejam.Canvas.Inode, foreign_key: :parent_inode_id, type: :binary_id)
    has_many(:children, Codejam.Canvas.Inode, foreign_key: :parent_inode_id)
    belongs_to(:organization, Codejam.Accounts.Organization, type: :binary_id)
    belongs_to(:snapshot, Codejam.Canvas.Snapshot, type: :binary_id)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:path, :name, :is_file, :is_dir])
    |> validate_required([:path, :name, :is_file, :is_dir])
  end
end
