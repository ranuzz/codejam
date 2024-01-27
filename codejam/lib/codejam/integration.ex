defmodule Codejam.Integration do
  use Ecto.Schema
  import Ecto.Changeset
  # Imports only from/2 of Ecto.Query
  import Ecto.Query, only: [from: 2]

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "integrations" do
    field(:service, :string)
    field(:access_token, :string)

    belongs_to(:organization, Codejam.Accounts.Organization, type: :binary_id)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(integration, attrs) do
    integration
    |> cast(attrs, [:service, :access_token])
    |> validate_required([:service, :access_token])
  end

  def add_integration(service, accress_token, organization_id) do
    Codejam.Repo.insert(%Codejam.Integration{
      service: service,
      access_token: accress_token,
      organization_id: organization_id
    })
  end

  def get_first_integration(organization_id) do
    hd(
      Codejam.Repo.all(
        from integtration in Codejam.Integration,
          where: integtration.organization_id == ^organization_id
      )
    )
  end
end
