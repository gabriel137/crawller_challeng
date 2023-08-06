defmodule TestKonsiWeb.CrawlerController do
  use TestKonsiWeb, :controller
  alias TestKonsi.{Crawler, Redis}

  def collect_data(conn, %{"cpf" => cpf, "credentials" => credentials}) do
      Crawler.enqueue_cpf(cpf, credentials)

      json(conn, %{message: "Buscando dados."})
  end

  def get_data(conn, %{"cpf" => cpf}) do
    case Redis.get_pid_from_redis(cpf) do
      {:ok, pid} ->
        case Redis.get_data_from_redis(pid) do
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

end
