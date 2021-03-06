defmodule AwesomeElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    children = [
      # Start the Parser supervisor
      AwesomeElixir.Parser,
      # Start the PubSub system
      {Phoenix.PubSub, name: AwesomeElixir.PubSub},
      # Start the Endpoint (http/https)
      AwesomeElixirWeb.Endpoint
      # Start a worker by calling: AwesomeElixir.Worker.start_link(arg)
      # {AwesomeElixir.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AwesomeElixir.Supervisor]
    result = Supervisor.start_link(children, opts)

    create_table(:awesome_elixir)
    result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AwesomeElixirWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp create_table(name) do
    :ets.new(name, [:set, :public, :named_table, read_concurrency: true])
  end
end
