defmodule TestKonsi.Redis do

  def start_link do
    Redix.start_link(host: Application.get_env(:test_konsi, TestKonsi.Crawler)[:redis_url])
  end

  def store_data(data) do
    redis_url = Application.get_env(:test_konsi, TestKonsi.Crawler)[:redis_url]

    case Redix.start_link(redis_url) do
      {:ok, redix} ->
        key = generate_redis_key()
        Redix.command(redix, ["SET", key, Poison.encode!(data)])

        cpf = data["cpf"]
        pid = self() |> Process.pid() |> to_string()
        Redix.command(redix, ["HSET", "cpf_to_pid", cpf, pid])

        # Feche a conexão com o Redis
        Redix.stop(redix)

        {pid, key}
      _ ->
        IO.puts("Erro ao conectar ao Redis.")
        {nil, nil}
    end
  end

  defp generate_redis_key() do
    "data_#{Base.encode16(:erlang.unique_integer([:positive, :monotonic]))}"
  end

  def get_data_from_redis(pid) do
    redis_url = Application.get_env(:test_redis, TestRedis.Crawler)[:redis_url]

    case Redix.start_link(redis_url) do
      {:ok, redix} ->
        key = "data_#{pid}"
        case Redix.command(redix, ~w(GET) [key]) do
          {:ok, data_json} ->
            # Deserialize os dados do JSON
            {:ok, data} = Poison.decode(data_json)
            Redix.stop(redix)
            {:ok, data}

          :nil ->
            Redix.stop(redix)
            {:error, "Dados não encontrados"}

          _ ->
            Redix.stop(redix)
            {:error, "Erro ao buscar dados no Redis"}
        end
      _ ->
        {:error, "Erro ao conectar ao Redis"}
    end
  end
end
