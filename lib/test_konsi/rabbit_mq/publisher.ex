defmodule TestKonsi.RabbitMQ.Publisher do
  @queue_name "test_konsi_queue"
  @exchange_name "test_konsi_exchange"

  def enqueue_cpfs(list_cpf, credentials) do
    {:ok, chan} = AMQP.Application.get_channel(:mychan)

    AMQP.Basic.publish(chan, @exchange_name, @queue_name, Poison.encode!(%{"list_cpf" => list_cpf, "credentials" => credentials}))
  end
end
