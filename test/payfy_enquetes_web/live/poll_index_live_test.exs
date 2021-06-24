defmodule PayfyEnquetesWeb.PollIndexLiveTest do
  use PayfyEnquetesWeb.ConnCase

  import Phoenix.LiveViewTest
  alias PayfyEnquetes.AccountsFixtures

  setup %{} do
    user = AccountsFixtures.user_fixture()

    %{user: user}
  end

  test "renders all polls", %{conn: conn, user: user} do
    poll_1 =
      create_poll(
        user_id: user.id,
        title: "Poll 1",
        question: "Poll 1 question",
        url_path: "poll-one"
      )

    poll_2 =
      create_poll(
        user_id: user.id,
        title: "Poll 2",
        question: "Poll 2 question",
        url_path: "poll-two"
      )

    poll_3 =
      create_poll(
        user_id: user.id,
        title: "Poll 3",
        question: "Poll 3 question",
        url_path: "poll-three"
      )

    {:ok, view, _html} = live(conn, "/enquetes")

    assert has_element?(view, poll_card(poll_1.id))
    assert has_element?(view, poll_card(poll_2.id))
    assert has_element?(view, poll_card(poll_3.id))
  end

  test "renders poll with title, question and user's email", %{conn: conn, user: user} do
    poll_1 =
      create_poll(
        user_id: user.id,
        title: "Poll 1",
        question: "Poll 1 question",
        url_path: "poll-one"
      )

    {:ok, view, _html} = live(conn, "/enquetes")

    assert has_element?(view, "#poll-#{poll_1.id} p", poll_1.title)
    assert has_element?(view, "#poll-#{poll_1.id} p", "por: #{user.email}")
    assert has_element?(view, "#poll-#{poll_1.id} p", poll_1.question)
  end

  test "should redirect after click on poll", %{conn: conn, user: user} do
    poll =
      create_poll(
        user_id: user.id,
        title: "Poll 1",
        question: "Poll 1 question",
        url_path: "poll-one"
      )

    {:ok, view, _html} = live(conn, "/enquetes")

    view
    |> element(poll_card(poll.id))
    |> render_click()

    assert_redirect(view, "/enquetes/poll-one")
  end

  defp poll_card(poll_id), do: "#poll-#{poll_id}"

  def create_poll(attrs) do
    {:ok, poll} =
      attrs
      |> Enum.into(%{options: [%{name: "some option"}]})
      |> PayfyEnquetes.Polls.create_poll()

    poll
  end
end
