defmodule TestKonsiWeb.CrawlerController do
  use TestKonsiWeb, :controller
  alias TestKonsi.Crawler

  def collect_data(conn, %{"cpf" => cpf, "credentials" => credentials}) do
      spawn_link(fn ->
        Crawler.crawl_beneficios_cpf(cpf, credentials)
      end)
      json(conn, %{message: "Buscando dados."})
  end

  def get_data(conn, %{"cpf" => cpf}) do
    case get_pid_from_redis(cpf) do
      {:ok, pid} ->
        case Crawler.get_data_from_redis(pid) do
          {:ok, data} ->
            json(conn, data)

          {:error, reason} ->
            conn
            |> put_status(:not_found)
            |> json(%{error: reason})
        end

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: reason})
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
