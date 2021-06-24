defmodule PayfyEnquetes.Polls.PollOption do
  use PayfyEnquetes.Schema
  import Ecto.Changeset

  alias PayfyEnquetes.Polls.Poll

  schema "poll_options" do
    field :name, :string

    belongs_to :poll, Poll

    timestamps(updated_at: false)
  end

  def create_changeset_via_poll(%__MODULE__{} = poll, params) do
    poll
    |> cast(params, [:name, :poll_id])
    |> validate_required([:name], message: "Esse campo é obrigatório")
    |> unique_constraint(:name)
    |> assoc_constraint(:poll, message: "invalid FK poll_id")
  end
end
