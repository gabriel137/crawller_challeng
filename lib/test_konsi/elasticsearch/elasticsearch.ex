defmodule TestKonsi.Crawler.Elasticsearch do
  defp index_data(cpf, data) do
    # Configurações do índice no Elasticsearch
    index = "beneficios"
    type = "dados"

    # Prepare o documento a ser indexado
    document = %{
      "cpf" => cpf,
      "beneficios" => data
    }

    # Realize a indexação utilizando o ex_elasticsearch
    case Elasticsearch.Index.index(index, type, document) do
      {:ok, _result} ->
        IO.puts("Dados indexados com sucesso!")
      {:error, reason} ->
        IO.puts("Erro na indexação: #{reason}")
    end
  end

  defp search_beneficios(cpf) do
    # Configurações do índice no Elasticsearch
    index = "beneficios"
    type = "dados"

    # Consulta os dados no Elasticsearch
    query = %{
      "query" => %{
        "match" => %{"cpf" => cpf}
      }
    }

    case Elasticsearch.Client.search(index, type, query) do
      {:ok, result} ->
        # Processar os resultados da pesquisa (result["hits"]["hits"])
        result
      {:error, reason} ->
        IO.puts("Erro na consulta: #{reason}")
        []
    end
  end

end
