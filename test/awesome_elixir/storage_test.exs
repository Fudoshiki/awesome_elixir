defmodule AwesomeElixir.StorageTest do
  use AwesomeElixir.DataCase
  use ExUnit.Case, async: true

  alias AwesomeElixir.Storage

  setup_all do
    repos = Enum.map(1..100, fn _repo -> repo_section_fixture() end)
    :ets.insert(:awesome_elixir, {:list, repos})

    [repos: repos]
  end

  describe "get_repos/1" do
    test "with min_stars param", %{repos: repos} do
      min_stars = 1000

      repos =
        Enum.reduce(repos, [], fn item, list ->
          repos =
            Enum.filter(item.repos, fn repo ->
              case Map.get(repo, :stars) do
                nil -> false
                stars -> stars >= min_stars
              end
            end)

          if length(repos) > 0 do
            item = Map.put(item, :repos, repos)
            list ++ [item]
          else
            list
          end
        end)

      assert Storage.get_repos(%{"min_stars" => "#{min_stars}"}) == repos
    end

    test "with invalid param", %{repos: repos} do
      assert Storage.get_repos(%{"max_age" => "12"}) == repos
    end

    test "without param", %{repos: repos} do
      assert Storage.get_repos() == repos
    end
  end

  test "insert_repos/1", %{repos: repos} do
    Storage.insert_repos(repos)
    [list: list] = :ets.tab2list(:awesome_elixir)

    assert list == repos
  end

  test "subscribe/1" do
    Storage.subscribe()
    Phoenix.PubSub.broadcast(AwesomeElixir.PubSub, "storage", "update")

    assert_receive "update", 3_000
  end

  test "broadcast_update/0" do
    Phoenix.PubSub.subscribe(AwesomeElixir.PubSub, "storage")
    Storage.broadcast_update()

    assert_receive "update", 3_000
  end
end
