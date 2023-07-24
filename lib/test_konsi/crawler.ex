defmodule TestKonsi.Crawler do
  use Hound.Helpers

  alias TestKonsi.Redis
  alias TestKonsi.RabbitMQ
  alias TestKonsi.Elasticsearch

  @base_url "http://extratoclube.com.br/"

  # Inicia conexão com o Redis e RabbitMQ
  def start_link do
    Redis.start_link()
    RabbitMQ.start_link()
  end

  # Inicia o processo de coleta de dados
  def start_rabbitmq_consuming do
    RabbitMQ.start_consuming(self())
    IO.puts("Processo iniciado. Aguardando mensagens...")
  end

  def enqueue_matriculas(matriculas) do
    RabbitMQ.enqueue_matriculas(matriculas)
  end

  # Realiza o crawler dos benefícios de um CPF
  def crawl_beneficios_cpf(cpf, credentials) do
    # start_rabbitmq_consuming()

    # case Redis.check_redis_cache(cpf) do
    #   {:ok, data} ->
    #     {:ok, data}
    #   :not_found ->
        case login_portal(credentials) do
          :ok ->
            case navigate_to_beneficios_cpf() do
              :ok ->
                case consultar_beneficios(cpf) do
                  {:ok, beneficios} ->
                    {pid, key} =
                      # Redis.store_data(beneficios)
                      # Elasticsearch.index_data(cpf, beneficios)

                      {:ok, beneficios}
                  {:error, reason} ->
                    # Tratar o erro de consulta
                    {:error, reason}
                end
              {:error, reason} ->
                # Tratar o erro ao navegar para a página de benefícios do CPF
                {:error, reason}
            end
          {:error, reason} ->
            # Tratar o erro de login
            {:error, reason}
        end
    # end
  end

  defp login_portal(credentials) do
    Hound.start_session() |> IO.inspect
    navigate_to(@base_url)
    :timer.sleep 10_000

    element_login = find_element(:id, "user")
    fill_field(element_login, "konsi")
    element_password = find_element(:id, "pass")
    fill_field(element_password, "konsi")

    IO.puts("Login realizado com sucesso!")
    :timer.sleep 500_000
  end

  defp navigate_to_beneficios_cpf() do
    # Implementar a lógica para navegar até a página de "Benefícios de um CPF"
    # Use Hound para interagir com o menu de opções e clicar na opção desejada
    # Exemplo simplificado:
    IO.puts("Navegando até a página de 'Benefícios de um CPF'...")
    :ok
  end

  def consultar_beneficios(cpf) do
    # Implementar a lógica para consultar os benefícios do CPF
    # Use Hound para preencher o formulário de consulta e extrair os resultados
    # Retornar os benefícios encontrados em formato adequado
    # Exemplo simplificado:
    beneficios = %{}
    {:ok, beneficios}
  end

  defp store_data_in_redis(data) do
    Redis.store_data(data)
  end

  defp index_data_in_elasticsearch(cpf, data) do
    Elasticsearch.index_data(cpf, data)
  end
end
