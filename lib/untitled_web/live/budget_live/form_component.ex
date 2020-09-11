defmodule UntitledWeb.BudgetLive.FormComponent do
  use UntitledWeb, :live_component

  alias Untitled.Chronoallot

  @impl true
  def update(%{budget: budget} = assigns, socket) do
    changeset = Chronoallot.change_budget(budget)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"budget" => budget_params}, socket) do
    changeset =
      socket.assigns.budget
      |> Chronoallot.change_budget(budget_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"budget" => budget_params}, socket) do
    save_budget(socket, socket.assigns.action, budget_params)
  end

  defp save_budget(socket, :edit, budget_params) do
    case Chronoallot.update_budget(socket.assigns.budget, budget_params) do
      {:ok, _budget} ->
        {:noreply,
         socket
         |> put_flash(:info, "Budget updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_budget(socket, :new, budget_params) do
    case Chronoallot.create_budget(budget_params) do
      {:ok, _budget} ->
        {:noreply,
         socket
         |> put_flash(:info, "Budget created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
