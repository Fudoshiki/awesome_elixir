defmodule AwesomeElixirWeb.PageLiveTest do
  use AwesomeElixirWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "<h1 class=\"h1\">Awesome Elixir</h1>"
    assert render(page_live) =~ "<h2 class=\"f1\">Contents</h2>"
  end
end
