defmodule AwesomeElixir.Storage do
  def broadcast_update do
    Phoenix.PubSub.broadcast(AwesomeElixir.PubSub, "storage", "update")
  end

  def get_repos(%{"min_stars" => stars}) do
    stars_count =
      case Integer.parse(stars) do
        {int, _} -> int
        _ -> 0
      end

    case :ets.lookup(:awesome_elixir, :list) do
      [{:list, list}] -> list
      result -> result
    end
    |> Enum.reduce([], fn item, list ->
      repos =
        Enum.filter(item.repos, fn repo ->
          case Map.get(repo, :stars) do
            nil -> false
            stars -> stars >= stars_count
          end
        end)

      if length(repos) > 0 do
        item = Map.put(item, :repos, repos)
        list ++ [item]
      else
        list
      end
    end)
  end

  def get_repos(_), do: get_repos()

  def get_repos do
    case :ets.lookup(:awesome_elixir, :list) do
      [{:list, list}] -> list
      result -> result
    end
  end

  def insert_repos(list) do
    :ets.insert(:awesome_elixir, {:list, list})
    broadcast_update()
  end

  def subscribe do
    Phoenix.PubSub.subscribe(AwesomeElixir.PubSub, "storage")
  end
end
