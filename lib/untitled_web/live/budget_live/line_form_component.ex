defmodule UntitledWeb.BudgetLineLive.FormComponent do
  use UntitledWeb, :live_component

  alias Untitled.Chronoallot

  @impl true
  def update(%{budget_line: budget_line} = assigns, socket) do
    changeset = Chronoallot.change_budget_line(budget_line)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  @spec handle_event(<<_::32, _::_*32>>, map, Phoenix.LiveView.Socket.t()) :: {:noreply, any}
  def handle_event("validate", %{"budget_line" => budget_line_params}, socket) do
    changeset =
      socket.assigns.budget_line
      |> Chronoallot.change_budget_line(budget_line_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"budget_line" => budget_line_params}, socket) do
    save_budget_line(socket, socket.assigns.action, budget_line_params)
  end

  defp save_budget_line(socket, :edit, budget_line_params) do
    case Chronoallot.update_budget_line(socket.assigns.budget_line, budget_line_params) do
      {:ok, _budget_line} ->
        {:noreply,
         socket
         |> put_flash(:info, "Budget line updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_budget_line(socket, :new, budget_line_params) do
    case Chronoallot.create_budget_line(budget_line_params) do
      {:ok, _budget_line} ->
        {:noreply,
         socket
         |> put_flash(:info, "Budget line created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
