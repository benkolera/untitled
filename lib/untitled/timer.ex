defmodule Untitled.Timer do
  use GenServer
  require Logger

  @name {:global, __MODULE__}

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: @name)
  end

  def start(duration \\ 1500) do
    GenServer.call(@name, {:start, duration})
  end

  def cancel() do
    send(@name, :cancel)
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
    {:noreply, %{timer_ref: nil, timer: nil, caller: nil}}
  end

  def handle_info(:update, %{timer: 0, caller: from}) do
    send(from, {__MODULE__, :done})
    {:noreply, %{timer_ref: nil, timer: nil, caller: nil}}
  end

  def handle_info(:update, %{timer: time, caller: from}) do
    leftover = time - 1
    timer_ref = schedule_timer(1_000)
    send(from, {__MODULE__, :tick, leftover})
    {:noreply, %{timer_ref: timer_ref, timer: leftover, caller: from}}
  end

  @impl true
  def handle_call({:start, duration}, {caller_pid, _}, %{timer_ref: old_timer_ref}) do
    cancel_timer(old_timer_ref)
    timer_ref = schedule_timer(1_000)
    {:reply, duration, %{timer_ref: timer_ref, timer: duration, caller: caller_pid}}
  end

  defp schedule_timer(interval), do: Process.send_after(self(), :update, interval)
  defp cancel_timer(nil), do: :ok
  defp cancel_timer(ref), do: Process.cancel_timer(ref)
end
