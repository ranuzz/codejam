defmodule Codejam.Repo.Migrations.CreateInitialTables do
  use Ecto.Migration

  def common() do
    add(:created_by_membership_id, references(:memberships, type: :uuid, on_delete: :delete_all),
      null: true
    )

    add(:organization_id, references(:organizations, type: :uuid, on_delete: :delete_all),
      null: false
    )

    timestamps(type: :utc_datetime)
  end

  def change do
    # extension to support case insensitive string column type
    execute("CREATE EXTENSION IF NOT EXISTS citext", "")

    create table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:email, :citext, null: false)
      add(:hashed_password, :string, null: false)
      add(:confirmed_at, :naive_datetime)
      add(:role, :string, null: false)
      add(:name, :string)
      add(:avatar, :string)
      timestamps(type: :utc_datetime)
    end

    create(unique_index(:users, [:email]))

    create table(:users_tokens, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false)
      add(:token, :binary, null: false)
      add(:context, :string, null: false)
      add(:sent_to, :string)
      timestamps(updated_at: false)
    end

    create(index(:users_tokens, [:user_id]))
    create(unique_index(:users_tokens, [:context, :token]))

    create table(:organizations, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      timestamps(type: :utc_datetime)
    end

    create(unique_index(:organizations, [:name]))

    create table(:memberships, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:role, :string)

      # Only one membership can be active per user
      add(:active, :boolean, default: false)

      add(:organization_id, references(:organizations, type: :uuid, on_delete: :delete_all),
        null: false
      )

      # organization admins can invite user and create a placeholder membership
      add(:invited_name, :string)
      add(:invited_email, :string)
      # user_id can be null if this membership was created via invitaion
      # and the user invitation is pending
      add(:user_id, references(:users, type: :uuid, on_delete: :delete_all))
      timestamps(type: :utc_datetime)
    end

    create(index(:memberships, [:organization_id]))
    create(index(:memberships, [:user_id]))

    create table(:integrations, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:service, :string)
      add(:access_token, :string)
      common()
    end

    create(index(:integrations, [:organization_id]))

    create table(:projects, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:url, :string)
      add(:name, :string)
      add(:branch, :string)
      common()
    end

    create(index(:projects, [:organization_id]))

    create table(:git_objects, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:object_type, :string)
      add(:sha, :string)

      # applies to object type commit
      add(:tree, :string)
      # applies to object type tree & blob
      add(:path, :string)
      # applies to object type blob & tree
      # base64 content or path to storage for blob
      # comma separated sha for tree
      add(:content, :text)

      add(:project_id, references(:projects, type: :uuid, on_delete: :delete_all), null: false)
      common()
    end

    create(index(:git_objects, [:organization_id]))

    create table(:notebooks, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:title, :string)
      add(:kind, :string)
      add(:project_id, references(:projects, type: :uuid, on_delete: :delete_all), null: false)
      common()
    end

    create(index(:notebooks, [:organization_id]))

    create table(:notes, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:content, :text)
      add(:lines, :string)
      add(:kind, :string)
      add(:seq, :integer)

      add(:git_object_id, references(:git_objects, type: :uuid, on_delete: :delete_all),
        null: false
      )

      add(:notebook_id, references(:notebooks, type: :uuid, on_delete: :delete_all), null: false)
      common()
    end

    create(index(:notes, [:organization_id]))

    create table(:note_members, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:association, :string)
      add(:note_id, references(:notes, type: :uuid, on_delete: :delete_all), null: true)

      add(:membership_id, references(:memberships, type: :uuid, on_delete: :delete_all),
        null: false
      )

      common()
    end

    create(index(:note_members, [:organization_id]))
  end
end
