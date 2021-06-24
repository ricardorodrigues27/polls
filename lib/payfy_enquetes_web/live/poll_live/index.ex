defmodule PayfyEnquetesWeb.PollLive.Index do
  use PayfyEnquetesWeb, :live_view

  alias PayfyEnquetes.Polls

  @impl true
  def mount(_params, _session, socket) do
    polls = Polls.list_polls()
    {:ok, assign(socket, polls: polls)}
  end

  @impl true
  def handle_event("redirect_poll", %{"url-path" => url_path}, socket) do
    {:noreply, push_redirect(socket, to: Routes.poll_show_path(socket, :show, url_path))}
  end
end
