# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PayfyEnquetes.Repo.insert!(%PayfyEnquetes.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias PayfyEnquetes.Accounts
alias PayfyEnquetes.Polls
alias PayfyEnquetes.Polls.PollOption
alias PayfyEnquetes.Polls.PollAnswer
alias PayfyEnquetes.Repo

{:ok, user} =
  Accounts.register_user(%{
    first_name: "Teste",
    last_name: "Teste",
    email: "richard27xt@gmail.com",
    password: "password_valid"
  })

{:ok, poll} =
  Polls.create_poll(%{
    title: "poll teste",
    url_path: "poll-teste",
    question: "question teste",
    user_id: user.id,
    options: [
      %{name: "option 1"},
      %{name: "option 2"},
      %{name: "option 3"},
      %{name: "option 4"}
    ]
  })

Polls.create_poll(%{
  title: "poll teste 2",
  url_path: "poll-teste-two",
  question: "question teste",
  user_id: user.id,
  options: [
    %{name: "option 1"},
    %{name: "option 2"},
    %{name: "option 3"},
    %{name: "option 4"}
  ]
})

poll_option_1 = Repo.get_by(PollOption, poll_id: poll.id, name: "option 1")
poll_option_2 = Repo.get_by(PollOption, poll_id: poll.id, name: "option 2")
poll_option_3 = Repo.get_by(PollOption, poll_id: poll.id, name: "option 3")
poll_option_4 = Repo.get_by(PollOption, poll_id: poll.id, name: "option 4")

Enum.map(1..10, fn _ ->
  PollAnswer.create_changeset(%PollAnswer{}, %{
    session_id: :crypto.strong_rand_bytes(32) |> Base.encode32(),
    poll_id: poll.id,
    poll_option_id: poll_option_1.id
  })
  |> Repo.insert()
end)

Enum.each(1..20, fn _ ->
  PollAnswer.create_changeset(%PollAnswer{}, %{
    session_id: :crypto.strong_rand_bytes(32) |> Base.encode32(),
    poll_id: poll.id,
    poll_option_id: poll_option_2.id
  })
  |> Repo.insert()
end)

Enum.each(1..5, fn _ ->
  PollAnswer.create_changeset(%PollAnswer{}, %{
    session_id: :crypto.strong_rand_bytes(32) |> Base.encode32(),
    poll_id: poll.id,
    poll_option_id: poll_option_3.id
  })
  |> Repo.insert()
end)

Enum.each(1..4, fn _ ->
  PollAnswer.create_changeset(%PollAnswer{}, %{
    session_id: :crypto.strong_rand_bytes(32) |> Base.encode32(),
    poll_id: poll.id,
    poll_option_id: poll_option_4.id
  })
  |> Repo.insert()
end)
