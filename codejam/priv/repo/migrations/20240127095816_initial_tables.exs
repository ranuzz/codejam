defmodule Codejam.Repo.Migrations.CreateInitialTables do
  use Ecto.Migration

  # alpha version of initial tables ** not final **

  def change do
    # extension to support case insensitive string column type
    execute("CREATE EXTENSION IF NOT EXISTS citext", "")

    # users table
    create table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:email, :citext, null: false)
      add(:hashed_password, :string, null: false)
      add(:confirmed_at, :naive_datetime)
      add(:role, :string, null: false)
      add(:name, :string)
      add(:avatar, :string, size: 1_000_000)
      timestamps(type: :utc_datetime)
    end

    create(unique_index(:users, [:email]))

    # user_tokens table
    # users_tokens 1:N users
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

    # organizations table
    create table(:organizations, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      timestamps(type: :utc_datetime)
    end

    create(unique_index(:organizations, [:name]))

    # memberships tables
    # A user can be a member in multiple organizations
    # memberships 1:N organizations
    # memberships 1:N users
    create table(:memberships, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:role, :string)

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

    # integrations table: represent the credential to access an external service
    # integrations N:1 organization_id
    create table(:integrations, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:service, :string)
      add(:access_token, :string)

      add(:organization_id, references(:organizations, type: :uuid, on_delete: :delete_all),
        null: false
      )

      timestamps(type: :utc_datetime)
    end

    create(index(:integrations, [:organization_id]))

    create table(:projects, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:url, :string)
      add(:name, :string)
      add(:api_url, :string)
      add(:commits_url, :string)
      add(:default_branch, :string)

      add(:integration_id, references(:integrations, type: :uuid, on_delete: :delete_all),
        null: false
      )

      add(:organization_id, references(:organizations, type: :uuid, on_delete: :delete_all),
        null: false
      )

      timestamps(type: :utc_datetime)
    end

    create(index(:projects, [:organization_id]))

    create table(:snapshots, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:branch, :string)
      add(:commit_hash, :string)
      add(:storage_path, :string)
      add(:project_id, references(:projects, type: :uuid, on_delete: :delete_all), null: false)

      add(:organization_id, references(:organizations, type: :uuid, on_delete: :delete_all),
        null: false
      )

      timestamps(type: :utc_datetime)
    end

    create(index(:snapshots, [:organization_id]))

    create table(:inodes, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:path, :string)
      add(:name, :string)
      add(:is_file, :boolean)
      add(:is_dir, :boolean)
      add(:parent_inode_id, references(:inodes, type: :uuid, on_delete: :delete_all), null: true)
      add(:snapshot_id, references(:snapshots, type: :uuid, on_delete: :delete_all), null: false)

      add(:organization_id, references(:organizations, type: :uuid, on_delete: :delete_all),
        null: false
      )

      timestamps(type: :utc_datetime)
    end

    create(index(:inodes, [:organization_id]))

    create table(:discussions, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:title, :string)

      add(:snapshot_id, references(:snapshots, type: :uuid, on_delete: :delete_all), null: false)

      add(:organization_id, references(:organizations, type: :uuid, on_delete: :delete_all),
        null: false
      )

      timestamps(type: :utc_datetime)
    end

    create(index(:discussions, [:organization_id]))

    # notes table: represent a note created in a git supported code repository
    # notes N:1 organizations
    # notes N:1 memberships
    create table(:notes, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:content, :string)
      # represent a block of code formatted as `line_start:line_end`
      add(:lines, :string)
      add(:parent_note_id, references(:notes, type: :uuid, on_delete: :delete_all), null: true)
      add(:inode_id, references(:inodes, type: :uuid, on_delete: :delete_all), null: false)

      add(:discussion_id, references(:discussions, type: :uuid, on_delete: :delete_all),
        null: false
      )

      add(:membership_id, references(:memberships, type: :uuid, on_delete: :delete_all),
        null: false
      )

      add(:organization_id, references(:organizations, type: :uuid, on_delete: :delete_all),
        null: false
      )

      timestamps(type: :utc_datetime)
    end

    create(index(:notes, [:organization_id]))
    create(index(:notes, [:membership_id]))
  end
end
