defmodule Untitled.Chronoallot do
  @moduledoc """
  The Chronoallot context.
  """

  import Ecto.Query, warn: false
  alias Untitled.Repo

  alias Untitled.Chronoallot.Category
  alias Untitled.Chronoallot.TimeLog
  alias Untitled.Chronoallot.Budget

  @topic inspect(__MODULE__)

  def subscribe_budgets do
    Phoenix.PubSub.subscribe(Untitled.PubSub, @topic)
  end

  def subscribe_budget(budget_id) do
    Phoenix.PubSub.subscribe(Untitled.PubSub, @topic <> "#{budget_id}")
  end

  def list_categories do
    Repo.all(Category)
  end

  def get_category!(id), do: Repo.get!(Category, id)

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  def list_budgets do
    Repo.all(Budget)
  end

  def get_budget!(id), do: Repo.get!(Budget, id)

  def create_budget(attrs \\ %{}) do
    %Budget{}
    |> Budget.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:budget, :created], & &1.id)
  end

  def update_budget(%Budget{} = budget, attrs) do
    budget
    |> Budget.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:budget, :updated], & &1.id)
  end

  def delete_budget(%Budget{} = budget) do
    Repo.delete(budget)
    |> notify_subscribers([:budget, :deleted], & &1.id)
  end

  def change_budget(%Budget{} = budget, attrs \\ %{}) do
    Budget.changeset(budget, attrs)
  end

  alias Untitled.Chronoallot.BudgetLine

  def list_budget_lines(budget_id) do
    BudgetLine
    |> Ecto.Query.where(budget_id: ^budget_id)
    |> Ecto.Query.order_by(asc: :id)
    |> Repo.all()
  end

  @spec get_budget_line!(any) :: any
  def get_budget_line!(id), do: Repo.get!(BudgetLine, id)

  def create_budget_line(attrs \\ %{}) do
    %BudgetLine{}
    |> BudgetLine.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:budget_line, :created], & &1.budget_id)
  end

  def update_budget_line(%BudgetLine{} = budget_line, attrs) do
    budget_line
    |> BudgetLine.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:budget_line, :updated], & &1.budget_id)
  end

  def delete_budget_line(%BudgetLine{} = budget_line) do
    Repo.delete(budget_line)
    |> notify_subscribers([:budget_line, :deleted], & &1.budget_id)
  end

  def change_budget_line(%BudgetLine{} = budget_line, attrs \\ %{}) do
    BudgetLine.changeset(budget_line, attrs)
  end

  def list_time_logs(budget_id) do
    Repo.all(
      from tl in TimeLog,
        where: tl.budget_id == ^budget_id,
        order_by: [asc: tl.day, asc: tl.id],
        select: tl
    )
  end

  def get_time_log!(id), do: Repo.get!(TimeLog, id)

  def create_time_log(attrs \\ %{}) do
    %TimeLog{}
    |> TimeLog.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:budget_line, :deleted], & &1.budget_id)
  end

  def update_time_log(%TimeLog{} = time_log, attrs) do
    time_log
    |> TimeLog.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:budget_line, :deleted], & &1.budget_id)
  end

  def delete_time_log(%TimeLog{} = time_log) do
    Repo.delete(time_log)
    |> notify_subscribers([:budget_line, :deleted], & &1.budget_id)
  end

  def change_time_logs(%TimeLog{} = time_log, attrs \\ %{}) do
    TimeLog.changeset(time_log, attrs)
  end

  defp notify_subscribers({:ok, result}, event, idFn) do
    id = idFn.(result)
    event_with_id = [id | event]
    Phoenix.PubSub.broadcast(Untitled.PubSub, @topic, {__MODULE__, event_with_id, result})

    Phoenix.PubSub.broadcast(
      Untitled.PubSub,
      @topic <> "#{id}",
      {__MODULE__, event_with_id, result}
    )

    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _, _), do: {:error, reason}
end
