defmodule PayfyEnquetes.Polls.Poll do
  use PayfyEnquetes.Schema
  import Ecto.Changeset

  alias PayfyEnquetes.Accounts.User
  alias PayfyEnquetes.Polls.PollOption

  schema "polls" do
    field :title, :string
    field :url_path, :string
    field :question, :string

    has_many(:options, PollOption, on_replace: :delete)

    belongs_to :user, User

    timestamps()
  end

  def create_changeset(%__MODULE__{} = poll, params) do
    poll
    |> cast(params, [:title, :url_path, :question, :user_id])
    |> validate_required([:title, :url_path, :question, :user_id],
      message: "Esse campo é obrigatório"
    )
    |> unique_constraint(:title, message: "Já existe uma enquete com esse título")
    |> unique_constraint(:url_path, message: "Já existe uma enquete com esse endereço")
    |> cast_assoc(:options,
      with: &PollOption.create_changeset_via_poll/2,
      required: true,
      required_message: "Deve ter ao menos uma resposta"
    )
    |> foreign_key_constraint(:user_id, message: "invalid FK user_id")
  end

  def build_url_path(""), do: ""
  def build_url_path(nil), do: ""

  def build_url_path(title) do
    title
    |> String.normalize(:nfd)
    |> String.downcase()
    |> String.trim()
    |> String.replace(~r/[^a-z\s]/u, "")
    |> String.replace(~r/[[:punct:]]/u, "")
    |> String.replace(~r/\s+/, "-")
  end
end
