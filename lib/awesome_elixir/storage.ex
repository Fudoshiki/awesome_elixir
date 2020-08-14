defmodule AwesomeElixir.Storage do
  def get_repos do
    case :ets.lookup(:awesome_elixir, :list) do
      [{:list, list}] -> list
      _ -> []
    end
  end

  def subscribe do
    Phoenix.PubSub.subscribe(AwesomeElixir.PubSub, "data")
  end

  def broadcast_update do
    Phoenix.PubSub.broadcast(AwesomeElixir.PubSub, "data", "update")
  end

  def insert_repos(list) do
    :ets.insert(:awesome_elixir, {:list, list})
    broadcast_update()
  end
end
