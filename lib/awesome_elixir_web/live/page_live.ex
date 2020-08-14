defmodule AwesomeElixirWeb.PageLive do
  use AwesomeElixirWeb, :live_view

  alias AwesomeElixir.Storage

  @impl true
  def render(assigns), do: AwesomeElixirWeb.PageView.render("index.html", assigns)

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Storage.subscribe()
    {:ok, fetch_repos(socket)}
  end

  @impl true
  def handle_info("update", socket), do: {:noreply, fetch_repos(socket)}
  def handle_info(_event, socket), do: {:noreply, socket}

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  defp fetch_repos(socket), do: assign(socket, repos: Storage.get_repos())
end
