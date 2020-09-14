defmodule Untitled.Timer do
  use GenServer
  require Logger

  @name {:global, __MODULE__}

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: @name)
  end

  def start(id, duration \\ 1500) do
    GenServer.call(@name, {:start, duration, id})
  end

  def cancel() do
    send(@name, :cancel)
  end

  def reconnect() do
    GenServer.call(@name, {:reconnect})
  end

  ## SERVER ##
  @impl true
  def init(_state) do
    Logger.warn("timer server started")
    state = %{timer_ref: nil, timer: nil, caller: nil}
    {:ok, state}
  end

  @impl true
  def handle_info(:cancel, %{timer_ref: ref}) do
    cancel_timer(ref)
    {:noreply, %{timer_ref: nil, timer: nil, caller: nil, id: nil}}
  end

  def handle_info(:update, %{timer: 0, caller: from}) do
    send(from, {__MODULE__, :done})
    {:noreply, %{timer_ref: nil, timer: nil, caller: nil, id: nil}}
  end

  def handle_info(:update, data) do
    leftover = data.timer - 1
    timer_ref = schedule_timer(1_000)
    send(data.caller, {__MODULE__, :tick, leftover})
    {:noreply, %{data | timer: leftover, timer_ref: timer_ref}}
  end

  @impl true
  def handle_call({:start, duration, id}, {caller_pid, _}, %{timer_ref: old_timer_ref}) do
    cancel_timer(old_timer_ref)
    timer_ref = schedule_timer(1_000)
    {:reply, duration, %{timer_ref: timer_ref, timer: duration, id: id, caller: caller_pid}}
  end

  def handle_call({:reconnect}, {caller_pid, _}, data) do
    IO.puts(inspect(data))

    if data.timer_ref != nil do
      {:reply, {data.timer, data.id}, %{data | caller: caller_pid}}
    else
      {:reply, nil, data}
    end
  end

  defp schedule_timer(interval), do: Process.send_after(self(), :update, interval)
  defp cancel_timer(nil), do: :ok
  defp cancel_timer(ref), do: Process.cancel_timer(ref)
end
