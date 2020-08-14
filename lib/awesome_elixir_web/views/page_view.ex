defmodule AwesomeElixirWeb.PageView do
  use AwesomeElixirWeb, :view

  def display_description(%{description: description}) do
    {:ok, description, _} = Earmark.as_html(description)
    raw(description |> String.slice(4..-6))
  end

  def display_description(_), do: nil

  def display_stars(%{stars: stars}), do: {:safe, " ⭐<sub>#{stars}</sub>"}
  def display_stars(_), do: nil

  def period_in_days(date) when is_binary(date) do
    {:ok, date, _} = DateTime.from_iso8601(date)
    Timex.diff(Timex.now(), date, :days)
  end

  def period_in_days(_), do: nil

  def display_days(%{last_update: last_update}) when is_binary(last_update) do
    days = period_in_days(last_update)
    {:safe, " 📅<sub>#{days}</sub>"}
  end

  def display_days(_), do: nil
end
