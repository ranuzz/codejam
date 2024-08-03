defmodule Codejam.Accounts.Integration do
  use Ecto.Schema
  import Ecto.Changeset
  alias Codejam.Accounts.Organization

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "integrations" do
    field(:service, :string)
    field(:access_token, :string)

    belongs_to(:organization, Organization, type: :binary_id)
    timestamps(type: :utc_datetime)
  end

  def changeset(integration, attrs) do
    integration
    |> cast(attrs, [:service, :access_token])
    |> validate_required([:service, :access_token])
  end
end
