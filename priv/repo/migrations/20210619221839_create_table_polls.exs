defmodule PayfyEnquetes.Repo.Migrations.CreateTablePolls do
  use Ecto.Migration

  def change do
    create table(:polls, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string, null: false
      add :url_path, :string, null: false
      add :question, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end

    create index(:polls, [:user_id])
    create unique_index(:polls, [:title])
    create unique_index(:polls, [:url_path])
  end
end
