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

    categories =
      Chronoallot.list_categories()
      |> Enum.map(fn x -> {x.id, x.name} end)
      |> Map.new()

    {:noreply,
     socket
     |> assign(:page_title, "Budget")
     |> load_budget(id)
     |> assign(:categories, categories)}
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
    IO.puts(inspect(budget_line_params))

    res =
      Chronoallot.get_budget_line!(budget_line_params["id"])
      |> Chronoallot.update_budget_line(Map.delete(budget_line_params, "id"))

    IO.puts(inspect(res))

    {:noreply, socket}
  end

  def handle_event("time_log_create", _data, socket) do
    {{y, m, d}, _} = :calendar.local_time()
    {:ok, date} = Date.new(y, m, d)

    res =
      Chronoallot.create_time_log(%{
        day: Date.to_iso8601(date),
        budget_id: socket.assigns.budget.id,
        hours: 0
      })

    IO.puts(inspect(res))
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

  @impl true
  def handle_info({Chronoallot, [id, _, _], _}, socket) do
    {:noreply, load_budget(socket, id)}
  end

  defp load_budget(socket, id) do
    weekly_hours = 24 * 7

    time_logs = Chronoallot.list_time_logs(id)

    time_spent =
      time_logs
      |> Enum.group_by(fn x -> x.budget_line_id end)
      |> Enum.map(fn {k, v} -> {k, v |> Enum.map(fn x -> x.hours end) |> Enum.sum()} end)
      |> Map.new()

    IO.puts(inspect(time_spent))

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
    |> assign(:time_logs, time_logs)
  end
end
