defmodule Untitled.Chronoallot.BudgetLine do
  use Ecto.Schema
  import Ecto.Changeset

  schema "budget_lines" do
    field :hours, :float
    field :category_id, :id
    field :budget_id, :id

    timestamps()
  end

  @doc false
  def changeset(budget_line, attrs) do
    budget_line
    |> cast(attrs, [:hours, :budget_id, :category_id])
    |> validate_required([:hours, :budget_id])
  end
end
