defmodule TestKonsi.Crawler do
  alias TestKonsi.Redis
  alias TestKonsi.RabbitMQ.{Consumer, Publisher}
  alias TestKonsi.Elasticsearch


  @url_login "http://extratoblubeapp-env.eba-mvegshhd.sa-east-1.elasticbeanstalk.com/login"
  @url_beneficio "http://extratoblubeapp-env.eba-mvegshhd.sa-east-1.elasticbeanstalk.com/offline/listagem/"


  def enqueue_cpf(list_cpf, credentials) do
    Publisher.enqueue_cpfs(list_cpf, credentials)
    Consumer.start_link()
  end

  def crawl_beneficios_cpf(cpf, credentials) do
    case Redis.check_redis_cache(cpf) do
      {:ok, data} ->
        {:ok, data}

      {:error, "Data not found"} ->
        case login_portal(credentials) do
          {:ok, token} ->
            case consultar_beneficios(cpf, token) do
              {:ok, beneficios} ->
                # Redis.store_data(cpf, beneficios)
                # Elasticsearch.index_data(cpf, beneficios)
                IO.puts "PASSOU TUDO"
                :timer.sleep 500_000
                {:ok, beneficios}

              {:error, reason} ->
                {:error, reason}
            end
          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  defp login_portal(credentials) do
    body = Jason.encode!(credentials)

    HTTPoison.start
    case HTTPoison.post(@url_login, body) do
      {:ok, %HTTPoison.Response{status_code: 200, headers: headers}} ->
        case Enum.find(headers, fn {key, _token} -> key == "Authorization" end) do
          {_, token} -> {:ok, token}

          nil -> nil
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

  def consultar_beneficios(cpfs, token) do
    headers = ["Authorization": token, "Accept": "Application/json; Charset=utf-8"]

    Enum.map(cpfs, fn cpf ->
      case HTTPoison.get(@url_beneficio <> "cpf=#{cpf}", headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          body
          |> Jason.decode()
          |> extract_beneficio(cpf)

        {:error, reason} ->
          {:error, reason}

        end
    end)

    beneficios = %{}
    {:ok, beneficios}
  end

  defp extract_beneficio({:ok, %{"beneficios" =>  [beneficio | _rest]}}, cpf) do
    %{cpf: cpf, beneficio: beneficio["nb"]}
  end
end
