defmodule UntitledWeb.BudgetLive.Show do
  use UntitledWeb, :live_view

  alias Untitled.Chronoallot

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  @spec handle_params(map, any, Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_params(%{"id" => id}, _, socket) do
    if connected?(socket), do: Chronoallot.subscribe_budget(id)

    timer = if connected?(socket), do: Untitled.Timer.reconnect()

    categories =
      Chronoallot.list_categories()
      |> Enum.map(fn x -> {x.id, x.name} end)
      |> Map.new()

    {:noreply,
     socket
     |> assign(:page_title, "Budget")
     |> load_budget(id)
     |> assign(:categories, categories)
     |> assign_timer_optional(timer)
     |> assign(:sounds, [])}
  end

  @impl true
  def handle_event("budget_line_create", _data, socket) do
    Chronoallot.create_budget_line(%{budget_id: socket.assigns.budget.id, hours: 0})
    {:noreply, socket}
  end

  def handle_event("budget_line_delete", %{"id" => id}, socket) do
    budget_line = Chronoallot.get_budget_line!(id)
    Chronoallot.delete_budget_line(budget_line)
    {:noreply, socket}
  end

  def handle_event("budget_line_update", budget_line_params, socket) do
    Chronoallot.get_budget_line!(budget_line_params["id"])
    |> Chronoallot.update_budget_line(Map.delete(budget_line_params, "id"))

    {:noreply, socket}
  end

  def handle_event("budget_line_create_time_log", budget_line_params, socket) do
    {:noreply, socket}
    new_time_log(socket.assigns.budget.id, 0, budget_line_params["id"])
    {:noreply, socket}
  end

  def handle_event("time_log_create", _data, socket) do
    new_time_log(socket.assigns.budget.id, 0, nil)
    {:noreply, socket}
  end

  def handle_event("time_log_delete", %{"id" => id}, socket) do
    time_log = Chronoallot.get_time_log!(id)
    Chronoallot.delete_time_log(time_log)
    {:noreply, socket}
  end

  def handle_event("time_log_update", time_log_params, socket) do
    Chronoallot.get_time_log!(time_log_params["id"])
    |> Chronoallot.update_time_log(Map.delete(time_log_params, "id"))
    |> inspect()
    |> IO.puts()

    {:noreply, socket}
  end

  def handle_event("timer_start", %{"id" => blid_str}, socket) do
    blid = String.to_integer(blid_str)
    {:noreply, assign_timer(socket, Untitled.Timer.start(blid, 60 * 25), blid)}
  end

  def handle_event("timer_stop", _, socket) do
    Untitled.Timer.cancel()
    {:noreply, assign(socket, :timer, nil)}
  end

  @impl true
  def handle_info({Chronoallot, [id, _, _], _}, socket) do
    {:noreply, load_budget(socket, id)}
  end

  def handle_info({Untitled.Timer, :done}, socket) do
    if socket.assigns.timer != nil do
      new_time_log(socket.assigns.budget.id, 0.5, socket.assigns.timer.budget_line_id)

      {:noreply,
       socket
       |> assign(:timer, nil)
       |> assign(:sounds, ["/sfx/alarm.mp3"])}
    else
      {:noreply, socket}
    end
  end

  def handle_info({Untitled.Timer, :tick, seconds_left}, socket) do
    if socket.assigns.timer != nil do
      {minutes, seconds} = calculate_minutes_seconds(seconds_left)

      sounds =
        if seconds_left > 0 and seconds == 0 do
          ["/sfx/bowl.mp3"]
        else
          []
        end

      {:noreply,
       socket
       |> update(:timer, fn x -> %{x | minutes: minutes, seconds: seconds} end)
       |> assign(:sounds, sounds)}
    else
      {:noreply, socket}
    end
  end

  defp load_budget(socket, id) do
    weekly_hours = 24 * 7
    time_logs = Chronoallot.list_time_logs(id)

    time_spent =
      time_logs
      |> Enum.group_by(fn x -> x.budget_line_id end)
      |> Enum.map(fn {k, v} -> {k, v |> Enum.map(fn x -> x.hours end) |> Enum.sum()} end)
      |> Map.new()

    time_logs_by_day =
      time_logs
      |> Enum.group_by(fn x -> x.day end)
      |> Enum.map(fn {d, logs} ->
        %{
          day: d,
          logs: logs,
          spent: logs |> Enum.map(fn x -> x.hours end) |> Enum.sum()
        }
      end)
      |> Enum.sort_by(fn m -> m.day end, :desc)

    lines =
      Chronoallot.list_budget_lines(id)
      |> Enum.map(fn x ->
        %{
          db: x,
          percentage: Float.round(x.hours / weekly_hours * 100, 2),
          remaining: x.hours - Map.get(time_spent, x.id, 0)
        }
      end)

    total_hours = lines |> Enum.map(& &1.db.hours) |> Enum.sum()
    remaining_hours = weekly_hours - total_hours

    socket
    |> assign(:budget, Chronoallot.get_budget!(id))
    |> assign(:budget_lines, lines)
    |> assign(:remaining_hours, remaining_hours)
    |> assign(:budget_hours, weekly_hours)
    |> assign(:time_logs, time_logs_by_day)
  end

  defp calculate_minutes_seconds(seconds_left) do
    {
      String.pad_leading(to_string(div(seconds_left, 60)), 2, "0"),
      String.pad_leading(to_string(rem(seconds_left, 60)), 2, "0")
    }
  end

  # todo should be in model
  defp new_time_log(budget_id, hours, budget_line_id) do
    date = today_date()

    res =
      Chronoallot.create_time_log(%{
        day: Date.to_iso8601(date),
        budget_id: budget_id,
        budget_line_id: budget_line_id,
        hours: hours
      })

    res
  end

  defp today_date() do
    {:ok, dt} = DateTime.now("Australia/Brisbane")
    DateTime.to_date(dt)
  end

  defp assign_timer(socket, seconds, budget_line_id) do
    {minutes, seconds} = calculate_minutes_seconds(seconds)

    assign(socket, :timer, %{
      budget_line_id: budget_line_id,
      minutes: minutes,
      seconds: seconds
    })
  end

  defp assign_timer_optional(socket, tpl) do
    if tpl != nil do
      {timer, blid} = tpl
      assign_timer(socket, timer, blid)
    else
      socket
      |> assign(timer: nil)
    end
  end
end
