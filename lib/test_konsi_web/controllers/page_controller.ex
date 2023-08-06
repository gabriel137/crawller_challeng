defmodule TestKonsiWeb.PageController do
  use TestKonsiWeb, :controller

  alias TestKonsi.Elasticsearch

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def search(conn, %{"cpf" => cpf}) do
    case Elasticsearch.search_beneficios(cpf) do
      {:ok, beneficios} ->
        render(conn, "results.html", beneficios: beneficios)
      {:error, reason} ->
        render(conn, "error.html", reason: reason)
    end
  end
end
