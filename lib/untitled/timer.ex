defmodule Untitled.Timer do
  use GenServer
  require Logger

  @topic inspect(__MODULE__)
  @name {:global, __MODULE__}

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: @name)
  end

  def start(id, duration \\ 1500) do
    GenServer.cast(@name, {:start, duration, id})
  end

  def cancel() do
    GenServer.cast(@name, :cancel)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(Untitled.PubSub, @topic)
    GenServer.cast(@name, {:reconnect})
  end

  ## SERVER ##
  @impl true
  def init(_state) do
    IO.puts("INIT")
    {:ok, nil}
  end

  @impl true
  def handle_info(:update, nil) do
    {:noreply, nil}
  end

  def handle_info(:update, %{timer: 0, id: id}) do
    broadcast({:done, id})
    {:noreply, nil}
  end

  def handle_info(:update, data) do
    leftover = data.timer - 1
    timer_ref = schedule_timer(1_000)
    broadcast({:tick, data.id, leftover})
    {:noreply, %{data | timer: leftover, timer_ref: timer_ref}}
  end

  @impl true
  def handle_cast({:start, duration, id}, data) do
    if data do
      cancel_timer(data.timer_ref)
    end

    timer_ref = schedule_timer(1_000)
    broadcast({:started, id, duration})
    {:noreply, %{timer_ref: timer_ref, timer: duration, id: id}}
  end

  def handle_cast({:reconnect}, data) do
    if data != nil do
      broadcast({:started, data.id, data.timer})
    end

    {:noreply, data}
  end

  def handle_cast(:cancel, nil) do
    {:noreply, nil}
  end

  def handle_cast(:cancel, %{timer_ref: ref, id: id}) do
    cancel_timer(ref)
    broadcast({:cancelled, id})
    {:noreply, nil}
  end

  defp schedule_timer(interval), do: Process.send_after(self(), :update, interval)
  defp cancel_timer(nil), do: :ok
  defp cancel_timer(ref), do: Process.cancel_timer(ref)

  defp broadcast(evt) do
    Phoenix.PubSub.broadcast(Untitled.PubSub, @topic, {__MODULE__, evt})
  end
end
