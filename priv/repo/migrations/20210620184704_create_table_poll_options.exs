defmodule PayfyEnquetes.Repo.Migrations.CreateTablePollOptions do
  use Ecto.Migration

  def change do
    create table(:poll_options, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :poll_id, references(:polls, on_delete: :delete_all), null: false
      add :name, :string
      timestamps(updated_at: false)
    end

    create index(:poll_options, [:poll_id])
    create unique_index(:poll_options, [:poll_id, :name])
  end
end
