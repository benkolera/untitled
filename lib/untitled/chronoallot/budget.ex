defmodule Untitled.Chronoallot.Budget do
  use Ecto.Schema
  import Ecto.Changeset

  schema "budgets" do
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(budget, attrs) do
    budget
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
