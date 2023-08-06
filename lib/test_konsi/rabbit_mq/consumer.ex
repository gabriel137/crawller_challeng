defmodule TestKonsi.RabbitMQ.Consumer do
  use GenServer
  use AMQP

  alias TestKonsi.Crawler

  def start_link() do
    GenServer.start_link(__MODULE__, [], [])
  end

  @exchange    "test_konsi_exchange"
  @queue       "test_konsi_queue"
  @queue_error "#{@queue}_error"


  def init(_opts) do
    # {:ok, conn} = Connection.open("amqp://guest:guest@rabbitmq")
    # {:ok, chan} = Channel.open(conn)
    {:ok, chan} = AMQP.Application.get_channel(:mychan)
    setup_queue(chan)

    # Limit unacknowledged messages to 10
    :ok = Basic.qos(chan, prefetch_count: 10)
    # Register the GenServer process as a consumer
    {:ok, _consumer_tag} = Basic.consume(chan, @queue)
    {:ok, chan}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, chan) do
    {:stop, :normal, chan}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}}, chan) do
    # You might want to run payload consumption in separate Tasks in production
    consume(chan, tag, redelivered, payload)
    {:noreply, chan}
  end

  defp setup_queue(chan) do
    {:ok, _} = Queue.declare(chan, @queue_error, durable: true)
    # Messages that cannot be delivered to any consumer in the main queue will be routed to the error queue
    {:ok, _} = Queue.declare(chan, @queue,
                             durable: true,
                             arguments: [
                               {"x-dead-letter-exchange", :longstr, ""},
                               {"x-dead-letter-routing-key", :longstr, @queue_error}
                             ]
                            )
    :ok = Exchange.fanout(chan, @exchange, durable: true)
    :ok = Queue.bind(chan, @queue, @exchange)
  end

  defp consume(channel, tag, redelivered, payload) do
    %{"list_cpf" => cpf, "credentials" => credentials} = Jason.decode!(payload)
    Crawler.crawl_beneficios_cpf(cpf, credentials)

  # rescue
  #   # Requeue unless it's a redelivered message.
  #   # This means we will retry consuming a message once in case of exception
  #   # before we give up and have it moved to the error queue
  #   #
  #   # You might also want to catch :exit signal in production code.
  #   # Make sure you call ack, nack or reject otherwise consumer will stop
  #   # receiving messages.
  #   _exception ->
  #     :ok = Basic.reject channel, tag, requeue: not redelivered
  #     IO.puts "Error converting #{payload} to integer"
  end
end
