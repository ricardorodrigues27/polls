defmodule PayfyEnquetes.Polls do
  @moduledoc """
  The Polls context.
  """

  import Ecto.Query, warn: false

  alias PayfyEnquetes.Polls.{Poll, PollOption, PollAnswer}
  alias PayfyEnquetes.Repo

  @doc """
  Gets a single poll by url_path.

  ## Examples

      iex> get_poll_by_url_path(path-valid)
      %Poll{}

      iex> get_poll_by_url_path(path-invalid)
      nil

  """
  def get_poll_by_url_path(url_path, opts \\ []) do
    preloads = Keyword.get(opts, :preload, [])

    Repo.get_by(Poll, url_path: url_path)
    |> Repo.preload(preloads)
  end

  @doc """
  Returns the list of polls.

  ## Examples

      iex> list_polls()
      [%Poll{}, ...]

  """
  def list_polls do
    Repo.all(from p in Poll, order_by: [desc: p.inserted_at], preload: [:user])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking poll changes.

  ## Examples

      iex> change_poll_changeset(poll)
      %Ecto.Changeset{data: %Poll{}}

  """
  def change_poll_changeset(%Poll{} = poll, attrs \\ %{}) do
    Poll.create_changeset(poll, attrs)
  end

  @doc """
  Create a poll.

  ## Examples

      iex> create_poll(%{field: value})
      {:ok, %Poll{}}

      iex> create_poll(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_poll(attrs) do
    %Poll{}
    |> Poll.create_changeset(attrs)
    |> Repo.insert()
  end

  ## Poll Answers

  def get_poll_results(poll_id) do
    query =
      PollOption
      |> where(poll_id: ^poll_id)
      |> join(:left, [po], pa in PollAnswer, on: po.id == pa.poll_option_id)
      |> group_by([po, pa], po.id)
      |> select([po, pa], %{
        name: po.name,
        total: count(pa.session_id)
      })

    from(q in subquery(query),
      select: %{
        name: q.name,
        total: q.total,
        percent: fragment("
        CASE total
          WHEN 0 THEN 0
          ELSE ROUND(CAST((? / SUM(?) OVER ()) as numeric), 2)
        END", q.total, q.total)
      },
      order_by: [desc: :total, asc: :name]
    )
    |> Repo.all()
  end

  def check_poll_answered_by_session?(poll_id, session_id) do
    PollAnswer
    |> where(poll_id: ^poll_id)
    |> where(session_id: ^session_id)
    |> Repo.exists?()
  end

  @doc """
  Create a poll answer.

  ## Examples

      iex> create_poll_answer(%{field: value})
      {:ok, %PollAnswer{}}

      iex> create_poll_answer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_poll_answer(attrs) do
    %PollAnswer{}
    |> PollAnswer.create_changeset(attrs)
    |> Repo.insert()
  end
end
