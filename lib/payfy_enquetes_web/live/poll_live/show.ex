defmodule PayfyEnquetesWeb.PollLive.Show do
  use PayfyEnquetesWeb, :live_view

  alias PayfyEnquetes.Polls

  @impl true
  def mount(%{"url_path" => url_path}, %{"session_id" => session_id}, socket) do
    socket =
      Polls.get_poll_by_url_path(url_path, preload: [:options])
      |> case do
        nil ->
          socket
          |> put_flash(:info, "Enquete não encontrada")
          |> push_redirect(to: "/enquetes")

        poll ->
          user_session_answered_poll? = Polls.check_poll_answered_by_session?(poll.id, session_id)

          socket
          |> assign(
            session_id: session_id,
            poll: poll,
            user_session_answered_poll?: user_session_answered_poll?,
            show_warning_poll?: false
          )
          |> assign_poll_results(poll.id)
      end

    {:ok, socket}
  end

  @impl true
  def handle_event("save_poll_answer", %{"poll" => %{"answer" => poll_option_id}}, socket) do
    %{session_id: session_id, poll: poll} = socket.assigns

    {:ok, _poll_answer} =
      %{session_id: session_id, poll_id: poll.id, poll_option_id: poll_option_id}
      |> Polls.create_poll_answer()

    {:noreply,
     assign(socket,
       user_session_answered_poll?: Polls.check_poll_answered_by_session?(poll.id, session_id),
       show_warning_poll?: false
     )
     |> assign_poll_results(poll.id)}
  end

  @impl true
  def handle_event("save_poll_answer", _params, socket) do
    {:noreply, assign(socket, show_warning_poll?: true)}
  end

  defp assign_poll_results(socket, poll_id) do
    poll_results = Polls.get_poll_results(poll_id)

    total_votes = Enum.reduce(poll_results, 0, fn x, acc -> x.total + acc end)

    assign(socket, poll_results: poll_results, total_votes: total_votes)
  end
end
