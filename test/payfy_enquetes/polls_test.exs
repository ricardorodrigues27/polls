defmodule PayfyEnquetes.PollsTest do
  use PayfyEnquetes.DataCase

  alias PayfyEnquetes.Accounts
  alias PayfyEnquetes.AccountsFixtures
  alias PayfyEnquetes.Polls
  alias PayfyEnquetes.Repo

  describe "polls" do
    alias PayfyEnquetes.Polls.Poll
    alias PayfyEnquetes.Polls.PollOption
    alias PayfyEnquetes.Polls.PollAnswer

    setup %{} do
      user = AccountsFixtures.user_fixture()

      %{user: user}
    end

    @valid_attrs %{
      title: "some title",
      url_path: "some-url-path",
      question: "some question",
      options: [
        %{
          name: "some option name"
        }
      ]
    }

    @invalid_attrs %{title: nil, url_path: nil, question: nil, options: nil}

    def poll_fixture(attrs \\ %{}) do
      {:ok, poll} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Polls.create_poll()

      poll
    end

    def poll_answer_fixture(attrs \\ %{}) do
      valid_session_id = :crypto.strong_rand_bytes(32) |> Base.encode32()

      {:ok, poll_answer} =
        attrs
        |> Enum.into(%{session_id: valid_session_id})
        |> Polls.create_poll_answer()

      poll_answer
    end

    test "list_polls/0 returns all polls", %{user: user} do
      %{id: poll_id} = poll_fixture(%{user_id: user.id})
      assert polls = Polls.list_polls()

      assert Enum.at(polls, 0).id == poll_id
    end

    test "change_poll_changeset/2 returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Polls.change_poll_changeset(%Poll{})
      assert changeset.required == [:options, :title, :url_path, :question, :user_id]
    end

    test "change_poll_changeset/2 allows fields to be set" do
      valid_attrs = %{
        title: "some title",
        url_path: "some url_path",
        question: "some question",
        user_id: Ecto.UUID.generate(),
        options: [%{name: "some option name"}]
      }

      changeset =
        Polls.change_poll_changeset(
          %Poll{},
          valid_attrs
        )

      assert changeset.valid?
      assert get_change(changeset, :title) == valid_attrs[:title]
      assert get_change(changeset, :url_path) == valid_attrs[:url_path]
      assert get_change(changeset, :question) == valid_attrs[:question]
      assert get_change(changeset, :user_id) == valid_attrs[:user_id]
    end

    test "get_poll_by_url_path/2 returns the poll with given url_path", %{user: user} do
      %{id: poll_id, url_path: poll_url_path} = poll_fixture(%{user_id: user.id})
      assert %Poll{id: ^poll_id} = Polls.get_poll_by_url_path(poll_url_path)
    end

    test "get_poll_by_url_path/2 returns the poll with preloads", %{user: user} do
      poll = poll_fixture(%{user_id: user.id})

      assert %{user: %Accounts.User{}, options: _options} =
               Polls.get_poll_by_url_path(poll.url_path, preload: [:user, :options])
    end

    test "create_poll/1 with valid data creates a poll", %{user: user} do
      assert {:ok, %Poll{} = poll} =
               @valid_attrs
               |> Enum.into(%{user_id: user.id})
               |> Polls.create_poll()

      assert poll.title == "some title"
      assert poll.url_path == "some-url-path"
      assert poll.question == "some question"
      assert poll.user_id == user.id
    end

    test "create_poll/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Polls.create_poll(@invalid_attrs)
    end

    test "get_poll_results/1 returns the poll results with given poll_id", %{user: user} do
      options = [%{name: "first option"}, %{name: "second option"}, %{name: "third option"}]
      poll = poll_fixture(%{user_id: user.id, options: options})

      first_option = Repo.get_by(PollOption, name: "first option")
      second_option = Repo.get_by(PollOption, name: "second option")

      # option 1 => 4/10 => 40%
      poll_answer_fixture(%{poll_id: poll.id, poll_option_id: first_option.id})
      poll_answer_fixture(%{poll_id: poll.id, poll_option_id: first_option.id})
      poll_answer_fixture(%{poll_id: poll.id, poll_option_id: first_option.id})
      poll_answer_fixture(%{poll_id: poll.id, poll_option_id: first_option.id})

      # option 2 => 6/10 => 60%
      poll_answer_fixture(%{poll_id: poll.id, poll_option_id: second_option.id})
      poll_answer_fixture(%{poll_id: poll.id, poll_option_id: second_option.id})
      poll_answer_fixture(%{poll_id: poll.id, poll_option_id: second_option.id})
      poll_answer_fixture(%{poll_id: poll.id, poll_option_id: second_option.id})
      poll_answer_fixture(%{poll_id: poll.id, poll_option_id: second_option.id})
      poll_answer_fixture(%{poll_id: poll.id, poll_option_id: second_option.id})

      poll_results = Polls.get_poll_results(poll.id)

      decimal_60 = Decimal.new("0.60")
      decimal_40 = Decimal.new("0.40")
      decimal_0 = Decimal.new("0")

      assert %{name: "second option", total: 6, percent: ^decimal_60} = Enum.at(poll_results, 0)

      assert %{name: "first option", total: 4, percent: ^decimal_40} = Enum.at(poll_results, 1)

      assert %{name: "third option", total: 0, percent: ^decimal_0} = Enum.at(poll_results, 2)
    end

    test "check_poll_answered_by_session?/2 check if session already answer poll", %{user: user} do
      options = [%{name: "option"}]
      session_id = :crypto.strong_rand_bytes(32) |> Base.encode32()
      other_session_id = :crypto.strong_rand_bytes(32) |> Base.encode32()
      poll = poll_fixture(%{user_id: user.id, options: options})

      option = Repo.get_by(PollOption, name: "option")

      assert {:ok, %PollAnswer{}} =
               Polls.create_poll_answer(%{
                 session_id: session_id,
                 poll_id: poll.id,
                 poll_option_id: option.id
               })

      assert Polls.check_poll_answered_by_session?(poll.id, session_id)
      refute Polls.check_poll_answered_by_session?(poll.id, other_session_id)
    end

    test "create_poll_answer/1 with valid data creates a poll answer", %{user: user} do
      options = [%{name: "option"}]
      session_id = :crypto.strong_rand_bytes(32) |> Base.encode32()
      poll = poll_fixture(%{user_id: user.id, options: options})

      option = Repo.get_by(PollOption, name: "option")

      assert {:ok, %PollAnswer{} = poll_answer} =
               Polls.create_poll_answer(%{
                 session_id: session_id,
                 poll_id: poll.id,
                 poll_option_id: option.id
               })

      assert poll_answer.poll_id == poll.id
      assert poll_answer.poll_option_id == option.id
      assert poll_answer.session_id == session_id
    end

    test "create_poll_answer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Polls.create_poll_answer(%{session_id: nil})
    end
  end
end
