defmodule PayfyEnquetesWeb.PollShowLiveTest do
  use PayfyEnquetesWeb.ConnCase

  import Phoenix.LiveViewTest
  alias PayfyEnquetes.AccountsFixtures
  alias PayfyEnquetes.Polls.PollOption
  alias PayfyEnquetes.Repo

  setup %{} do
    user = AccountsFixtures.user_fixture()

    %{user: user}
  end

  test "should render the poll to be answered", %{conn: conn, user: user} do
    create_poll(
      user_id: user.id,
      title: "Poll 1",
      question: "Poll 1 question",
      url_path: "poll-one",
      options: [%{name: "option 1"}, %{name: "option 2"}]
    )

    {:ok, view, _html} = live(conn, "/enquetes/poll-one")

    assert has_element?(view, "#poll_card_to_be_answered p", "Poll 1")
    assert has_element?(view, "#poll_card_to_be_answered p", "Poll 1 question")
    assert has_element?(view, "#poll_card_to_be_answered form#form_poll_options")
  end

  test "should render poll results after answer poll", %{conn: conn, user: user} do
    create_poll(
      user_id: user.id,
      title: "Poll 1",
      question: "Poll 1 question",
      url_path: "poll-one",
      options: [%{name: "option 1"}, %{name: "option 2"}]
    )

    poll_option_1 = Repo.get_by(PollOption, name: "option 1")

    {:ok, view, _html} = live(conn, "/enquetes/poll-one")

    view
    |> form("#form_poll_options", poll: %{answer: poll_option_1.id})
    |> render_submit()

    refute has_element?(view, "#poll_card_to_be_answered")
    assert has_element?(view, "#poll_card_results p", "Poll 1")
    assert has_element?(view, "#poll_card_results p", "Poll 1 question")
    assert has_element?(view, "#poll_options_card_results p", "option 1")
    assert has_element?(view, "#poll_options_card_results p", "option 2")
    assert has_element?(view, "#poll_total_votes", "Votos: 1")
  end

  test "should not anaswer the poll without choose an option", %{conn: conn, user: user} do
    create_poll(
      user_id: user.id,
      title: "Poll 1",
      question: "Poll 1 question",
      url_path: "poll-one",
      options: [%{name: "option 1"}, %{name: "option 2"}]
    )

    {:ok, view, _html} = live(conn, "/enquetes/poll-one")

    view
    |> form("#form_poll_options", poll: %{})
    |> render_submit()

    assert has_element?(
             view,
             "#poll_card_to_be_answered p",
             "Escolha uma das opções e clique em responder"
           )
  end

  defp create_poll(attrs) do
    {:ok, poll} =
      attrs
      |> Enum.into(%{options: [%{name: "some option"}]})
      |> PayfyEnquetes.Polls.create_poll()

    poll
  end
end
