defmodule PayfyEnquetes.Repo.Migrations.CreateTablePollAnswers do
  use Ecto.Migration

  def change do
    create table(:poll_answers, primary_key: false) do
      add :poll_id, references(:polls, on_delete: :delete_all), null: false
      add :poll_option_id, references(:poll_options, on_delete: :delete_all), null: false
      add :session_id, :string
      timestamps(updated_at: false)
    end

    create index(:poll_answers, [:poll_id])
    create index(:poll_answers, [:poll_option_id])
    create unique_index(:poll_answers, [:poll_id, :session_id])
  end
end
