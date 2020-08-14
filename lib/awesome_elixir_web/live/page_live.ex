defmodule AwesomeElixirWeb.PageLive do
  use AwesomeElixirWeb, :live_view

  alias AwesomeElixir.Storage

  @impl true
  def render(assigns), do: AwesomeElixirWeb.PageView.render("index.html", assigns)

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket), do: Storage.subscribe()
    {:ok, fetch_repos(socket, params)}
  end

  @impl true
  def handle_info("update", socket) do
    params = socket.assigns[:params]
    {:noreply, fetch_repos(socket, params)}
  end

  def handle_info(_event, socket), do: {:noreply, socket}

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  defp fetch_repos(socket, params) do
    assign(socket, repos: Storage.get_repos(params), params: params)
  end
end
