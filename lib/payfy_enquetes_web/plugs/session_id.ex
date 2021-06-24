defmodule PayfyEnquetesWeb.Plugs.SessionId do
  @behaviour Plug

  import Plug.Conn

  @rand_size 32

  @impl true
  def init(default), do: default

  @impl true
  def call(conn, _config) do
    case get_session(conn, :session_id) do
      nil ->
        session_id = unique_session_id()
        put_session(conn, :session_id, session_id)

      _session_id ->
        conn
    end
  end

  defp unique_session_id() do
    :crypto.strong_rand_bytes(@rand_size) |> Base.encode32()
  end
end
