defmodule Untitled.Repo.Migrations.RemoveBudgetWeek do
  use Ecto.Migration

  def change do
    alter table("budgets") do
      remove :week_code
    end
  end
end
