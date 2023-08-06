defmodule TestKonsi.Redis do

  @host Application.get_env(:test_konsi, TestKonsi.Crawler)[:redis_url]

  def check_redis_cache(cpf) do
    with {:ok, result} <- Redix.command(:redix, ["GET", "cpf_#{cpf}"])   do
      IO.puts "Entrei aqui nessa bagaca"
      {:ok, result}
    else
      :error ->
        {:error, "Data not found"}
    end
  end

  def cache_result(cpf, result) do
    with :ok <- Redix.command(:redix, ["SET", "cpf#{cpf}", result]) do
      # Resultado cacheado com sucesso
      :ok
    else
      _ ->
        # Trate o erro, se necessário
        :error
    end
  end

  def store_data(data) do
    case start_link() do
      {:ok, redix} ->
        key = generate_redis_key()
        Redix.command(redix, ["SET", key, Poison.encode!(data)])

        cpf = data["cpf"]
        pid = self()|> to_string()
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
    case start_link() do
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

  defp get_pid_from_redis(cpf) do
    redis_url = Application.get_env(:test_konsi, Crawler)[:redis_url]

    case Redix.start_link(redis_url) do
      {:ok, redix} ->
        case Redix.command(redix, ~w(HGET), ["cpf_to_pid", cpf]) do
          {:ok, pid} ->
            Redix.stop(redix)
            {:ok, pid}

          :nil ->
            Redix.stop(redix)
            {:error, "CPF não encontrado"}

          _ ->
            Redix.stop(redix)
            {:error, "Erro ao buscar o CPF no Redis"}
        end
      _ ->
        {:error, "Erro ao conectar ao Redis"}
    end
  end
end
