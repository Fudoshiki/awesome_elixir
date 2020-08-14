defmodule AwesomeElixirWeb.Router do
  use AwesomeElixirWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AwesomeElixirWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", AwesomeElixirWeb do
    pipe_through :browser

    live "/", PageLive, :index, container: {:main, class: "flex-1 mt-4"}
  end
end
