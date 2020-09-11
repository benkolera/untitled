defmodule Untitled.Repo.Migrations.CreateBudgets do
  use Ecto.Migration

  def change do
    create table(:budgets) do
      add :title, :string
      add :week_code, :string

      timestamps()
    end

  end
end
