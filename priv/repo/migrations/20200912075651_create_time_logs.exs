defmodule Untitled.Repo.Migrations.CreateTimeLogs do
  use Ecto.Migration

  def change do
    create table(:time_logs) do
      add :hours, :float
      add :notes, :string
      add :budget_line_id, references(:budget_lines, on_delete: :nothing)
      add :budget_id, references(:budget, on_delete: :nothing)
      add :day, :date

      timestamps()
    end

    create index(:time_logs, [:budget_line_id])
  end
end
