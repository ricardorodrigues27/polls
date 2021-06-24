defmodule PayfyEnquetesWeb.PageLiveTest do
  use PayfyEnquetesWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Bem vindo a PayfyEnquetes!"
    assert render(page_live) =~ "Bem vindo a PayfyEnquetes!"
  end

  test "should redirect after click on link", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    render(view)

    view
    |> element("#link_poll_index", "aqui")
    |> render_click()

    assert_redirect(view, "/enquetes")
  end
end
