defmodule TestKonsi.Elasticsearch do
  alias TestKonsi.Cluster, as: Elasticsearch
  
  def index_data(cpf, data) do
    index = "beneficios"
    type = "dados"

    document = %{
      "cpf" => cpf,
      "beneficios" => data
    }

    case Elasticsearch.index(index, type, document) do
      {:ok, _result} ->
        IO.puts("Dados indexados com sucesso!")
      {:error, reason} ->
        IO.puts("Erro na indexação: #{reason}")
    end
  end

  def search_beneficios(cpf) do
    index = "beneficios"
    type = "dados"

    query = %{
      "query" => %{
        "match" => %{"cpf" => cpf}
      }
    }

    case Elasticsearch.search(index, type, query) do
      {:ok, result} ->
        # Processar os resultados da pesquisa (result["hits"]["hits"])
        result
      {:error, reason} ->
        IO.puts("Erro na consulta: #{reason}")
        []
    end
  end

end
