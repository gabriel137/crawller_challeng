defmodule TestKonsi.RabbitMQ do
  def start_link do
    # Iniciar a conexão com RabbitMQ
    # Substitua "exchange" pelo nome da exchange apropriada em seu cenário.
    AMQP.Connection.open(Application.get_env(:test_konsi, TestKonsi.Crawler)[:rabbitmq_url], [exchange: "exchange"])
  end

  def enqueue_matriculas(matriculas) do
    # Estabelecer a conexão com o RabbitMQ
    {:ok, conn} = AMQP.Connection.open()

    # Criar um canal para interagir com o RabbitMQ
    {:ok, channel} = AMQP.Channel.open(conn)

    # Declarar a fila no RabbitMQ (se já existir, a declaração não afetará)
    AMQP.Queue.declare(channel, queue: "matriculas_queue")

    # Enfileirar os números de matrículas repetidos
    for matricula <- matriculas do
      AMQP.Basic.publish(channel, "", "matriculas_queue", Poison.encode!(%{"matricula" => matricula}))
    end

    # Fechar a conexão com o RabbitMQ
    AMQP.Connection.close(conn)
  end

  def handle_message(payload) do
    # Coloque aqui a lógica para processar o payload (dados recebidos) do RabbitMQ
    IO.inspect(payload)
  end
end
