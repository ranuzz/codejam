defmodule Codejam.Accounts.Membership do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Codejam.Accounts.{Membership, Organization, User}

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "memberships" do
    field(:role, :string)
    field(:active, :boolean)
    field(:invited_name, :string)
    field(:invited_email, :string)
    belongs_to(:organization, Organization, type: :binary_id)
    belongs_to(:user, User, type: :binary_id)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:role])
    |> validate_required([:role])
  end

  def user_id_changeset(membership, attrs) do
    membership
    |> cast(attrs, [:user_id])
  end

  def change_user_id(user, attrs \\ %{}) do
    Membership.user_id_changeset(user, attrs)
  end

  def update_user_id(membership, attrs) do
    changeset =
      membership
      |> Membership.change_user_id(attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:membership, changeset)
    |> Codejam.Repo.transaction()
    |> case do
      {:ok, %{membership: membership}} -> {:ok, membership}
      {:error, :membership, changeset, _} -> {:error, changeset}
    end
  end

  def user_id_query(user_id) do
    from(Membership, where: [user_id: ^user_id])
  end

  def user_email_query(email) do
    from(Membership, where: [invited_email: ^email])
  end

  def get_membership(user_id, organization_id) do
    Codejam.Repo.all(
      from(membership in Codejam.Accounts.Membership,
        where: membership.organization_id == ^organization_id and membership.user_id == ^user_id
      )
    )
  end

  def user_id_active_query(user_id) do
    from(Membership, where: [user_id: ^user_id, active: true], limit: 1)
  end
end
