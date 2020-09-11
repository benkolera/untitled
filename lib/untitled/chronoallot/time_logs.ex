defmodule Untitled.Chronoallot.TimeLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "time_logs" do
    field :hours, :float
    field :notes, :string
    field :budget_line_id, :id
    field :budget_id, :id
    field :day, :date

    timestamps()
  end

  @doc false
  def changeset(time_logs, attrs) do
    time_logs
    |> cast(attrs, [:hours, :notes, :budget_line_id, :budget_id, :day])
    |> validate_required([:hours, :day, :budget_id])
  end
end
