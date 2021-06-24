defmodule PayfyEnquetes.Polls.PollAnswer do
  use PayfyEnquetes.Schema
  import Ecto.Changeset

  alias PayfyEnquetes.Polls.{Poll, PollOption}

  @primary_key false

  schema "poll_answers" do
    field :session_id, :string

    belongs_to :poll, Poll
    belongs_to :poll_option, PollOption

    timestamps(updated_at: false)
  end

  def create_changeset(%__MODULE__{} = poll, params) do
    poll
    |> cast(params, [:session_id, :poll_id, :poll_option_id])
    |> validate_required([:session_id, :poll_id, :poll_option_id])
    |> foreign_key_constraint(:poll_id, message: "invalid FK poll_id")
    |> foreign_key_constraint(:poll_option_id, message: "invalid FK poll_option_id")
  end
end
