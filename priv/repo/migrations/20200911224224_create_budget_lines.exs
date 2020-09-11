defmodule Untitled.Repo.Migrations.CreateBudgetLines do
  use Ecto.Migration

  def change do
    create table(:budget_lines) do
      add :hours, :float
      add :category_id, references(:categories, on_delete: :nothing)
      add :budget_id, references(:budgets, on_delete: :nothing)

      timestamps()
    end

    create index(:budget_lines, [:category_id])
    create index(:budget_lines, [:budget_id])
  end
end
