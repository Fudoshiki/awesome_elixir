defmodule AwesomeElixir.RepoDataFixtures do
  def repo_fixture do
    name = Faker.Internet.user_name()
    slug = Faker.Internet.slug()

    %{
      description: Faker.Lorem.paragraph(),
      name: name,
      url: "https://github.com/#{name}/#{slug}",
      stars: Enum.random(0..10_000),
      last_update: Faker.DateTime.backward(100) |> DateTime.to_iso8601()
    }
  end

  def repo_section_fixture do
    name = Faker.StarWars.planet()
    slug = Faker.Internet.slug([name])

    %{
      description: Faker.Lorem.paragraph(),
      id: slug,
      name: name,
      repos: Enum.map(1..5, fn _ -> repo_fixture() end)
    }
  end
end
