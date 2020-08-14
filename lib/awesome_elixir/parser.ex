defmodule AwesomeElixir.Parser do
  use GenServer

  alias __MODULE__
  alias AwesomeElixir.Storage

  def start_link(state) do
    GenServer.start_link(Parser, state, name: Parser)
  end

  @impl true
  def init(state) do
    HTTPoison.start()
    update_content()
    {:ok, state}
  end

  def child_spec(arg) do
    %{id: Parser, start: {Parser, :start_link, [arg]}}
  end

  @impl true
  def handle_info(:update_content, state) do
    update_content()
    {:noreply, state}
  end

  def handle_info(_event, state) do
    {:noreply, state}
  end

  defp get_raw_content do
    awesome_repo_url = "https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md"

    case HTTPoison.get(awesome_repo_url) do
      {:ok, %{body: raw, status_code: 200}} ->
        content = String.split(raw, "\n")

        {_stage, list} = Enum.reduce(content, {}, fn line, result -> parse_line(line, result) end)
        Storage.insert_repos(list)

        update_repos(list)

      {:error, _error} ->
        nil
    end
  end

  defp parse_line("- [Awesome Elixir](#awesome-elixir)", _result), do: {:awesome, []}

  defp parse_line("    - " <> link, {:awesome, list}) do
    %{"id" => id, "name" => name} = Regex.named_captures(~r/\[(?<name>.+)\]\(\#(?<id>.+)\)/, link)
    {:awesome, list ++ [%{id: id, name: name}]}
  end

  defp parse_line("## " <> name, {_, contents}), do: {{:description, name}, contents}

  defp parse_line("* " <> repo, {{:repo, name}, list}) do
    regex = ~r/\[(?<name>.+)\]\((?<url>.+)\) - (?<description>.+)/

    %{"name" => repo_name, "url" => repo_url, "description" => repo_description} =
      Regex.named_captures(regex, repo)

    list =
      Enum.map(list, fn item ->
        if item[:name] == name do
          repos =
            Map.get(item, :repos, []) ++
              [%{name: repo_name, url: repo_url, description: repo_description}]

          Map.put(item, :repos, repos)
        else
          item
        end
      end)

    {{:repo, name}, list}
  end

  defp parse_line("*" <> description, {{:description, name}, list}) do
    description = String.slice(description, 0..-2)

    list =
      Enum.map(list, fn item ->
        case item[:name] == name do
          true -> Map.put(item, :description, description)
          _ -> item
        end
      end)

    {{:repo, name}, list}
  end

  defp parse_line("", result), do: result
  defp parse_line(_, {:awesome, contents}), do: {:complete, contents}
  defp parse_line(_, result), do: result

  defp update_repos(list) do
    for %{name: name, repos: repos} <- list do
      for repo <- repos do
        update_repo(name, repo)
        |> Storage.insert_repos()
      end
    end
  end

  defp update_repo(name, repo, new_url \\ nil) do
    list = Storage.get_repos()
    regex = ~r/https:\/\/github.com\/(?<repository>.+)/
    url = new_url || repo.url

    with true <- String.starts_with?(url, "https://github.com"),
         %{"repository" => repository} <- Regex.named_captures(regex, url) do
      case Tesla.get("https://api.github.com/repos/" <> repository,
             headers: [{"Authorization", "token 32ad212c062c9ae7a79dd545e4ea81104f2cde51"}]
           ) do
        {:ok, %{body: raw_json, status: 200}} ->
          %{"pushed_at" => last_update, "stargazers_count" => stars} = Jason.decode!(raw_json)

          Enum.map(list, fn item ->
            if item.name == name do
              repos =
                Enum.map(item.repos, fn r ->
                  if r.url == repo.url do
                    Map.put(r, :stars, stars)
                    |> Map.put(:last_update, last_update)
                  else
                    r
                  end
                end)

              Map.put(item, :repos, repos)
            else
              item
            end
          end)

        {:ok, %{status: status}} when status in [301, 404] ->
          case HTTPoison.get(url) do
            {:ok, %{headers: headers, status_code: 301}} ->
              {"location", location} = List.keyfind(headers, "location", 0)
              update_repo(name, repo, location)

            _ ->
              list
          end

        _ ->
          list
      end
    else
      _ ->
        list
    end
  end

  defp update_content do
    spawn(fn -> get_raw_content() end)
    Process.send_after(self(), :update_content, 24 * 60 * 60 * 1000)
  end
end
