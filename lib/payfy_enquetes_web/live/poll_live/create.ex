defmodule PayfyEnquetesWeb.PollLive.Create do
  use PayfyEnquetesWeb, :live_view

  alias PayfyEnquetes.Accounts
  alias PayfyEnquetes.Polls
  alias PayfyEnquetes.Polls.Poll

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    changeset = poll_changeset(%{options: []}, nil)

    {:ok,
     socket
     |> assign(changeset: changeset)
     |> assign_new(:current_user, fn -> Accounts.get_user_by_session_token(user_token) end)}
  end

  @impl true
  def handle_event("add_poll_option", _params, socket) do
    new_changeset = add_poll_option(socket.assigns.changeset)

    {:noreply, assign(socket, changeset: new_changeset)}
  end

  @impl true
  def handle_event("remove_poll_option", %{"index" => index}, socket) do
    new_changeset = remove_poll_option(socket.assigns.changeset, index)

    {:noreply, assign(socket, changeset: new_changeset)}
  end

  @impl true
  def handle_event(
        "validate_poll",
        %{"_target" => ["poll", "title"], "poll" => poll_attrs},
        socket
      ) do
    poll_url_path = Poll.build_url_path(poll_attrs["title"])

    poll_attrs = Map.merge(poll_attrs, %{"url_path" => poll_url_path})

    changeset = poll_changeset(poll_attrs)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("validate_poll", %{"poll" => poll_attrs}, socket) do
    changeset = poll_changeset(poll_attrs)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"poll" => poll_attrs}, socket) do
    case Polls.create_poll(poll_attrs) do
      {:ok, _poll} ->
        {:noreply, push_redirect(socket, to: "/enquetes")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp add_poll_option(%Ecto.Changeset{} = changeset) do
    new_options =
      changeset
      |> Ecto.Changeset.get_change(:options, [])
      |> Enum.concat([%{name: ""}])

    Ecto.Changeset.put_change(changeset, :options, new_options)
  end

  defp remove_poll_option(%Ecto.Changeset{} = changeset, index) do
    new_options =
      changeset
      |> Ecto.Changeset.get_change(:options, [])
      |> List.delete_at(String.to_integer(index))

    Ecto.Changeset.put_change(changeset, :options, new_options)
  end

  # defp add_poll_option(changeset) do
  #   Ecto.Changeset.put_change(changeset, :options, [%{name: ""}])
  # end

  defp poll_changeset(attrs, action \\ :change) do
    %Poll{}
    |> Polls.change_poll_changeset(attrs)
    |> Map.merge(%{action: action})
  end
end
