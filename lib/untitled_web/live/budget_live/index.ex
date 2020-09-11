defmodule UntitledWeb.BudgetLive.Index do
  use UntitledWeb, :live_view

  alias Untitled.Chronoallot
  alias Untitled.Chronoallot.Budget

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :budgets, list_budgets())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    {y, w} = :calendar.iso_week_number()

    socket
    |> assign(:page_title, "New Budget")
    |> assign(:budget, %Budget{title: "#{y}W#{w}"})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Budgets")
    |> assign(:budget, nil)
  end

  defp list_budgets do
    Chronoallot.list_budgets()
  end
end
