defmodule Untitled.ChronoallotTest do
  use Untitled.DataCase

  alias Untitled.Chronoallot

  describe "categories" do
    alias Untitled.Chronoallot.Category

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def category_fixture(attrs \\ %{}) do
      {:ok, category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chronoallot.create_category()

      category
    end

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Chronoallot.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Chronoallot.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      assert {:ok, %Category{} = category} = Chronoallot.create_category(@valid_attrs)
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chronoallot.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      assert {:ok, %Category{} = category} = Chronoallot.update_category(category, @update_attrs)
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Chronoallot.update_category(category, @invalid_attrs)
      assert category == Chronoallot.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Chronoallot.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Chronoallot.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Chronoallot.change_category(category)
    end
  end

  describe "budgets" do
    alias Untitled.Chronoallot.Budget

    @valid_attrs %{title: "some title", week_code: "some week_code"}
    @update_attrs %{title: "some updated title", week_code: "some updated week_code"}
    @invalid_attrs %{title: nil, week_code: nil}

    def budget_fixture(attrs \\ %{}) do
      {:ok, budget} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chronoallot.create_budget()

      budget
    end

    test "list_budgets/0 returns all budgets" do
      budget = budget_fixture()
      assert Chronoallot.list_budgets() == [budget]
    end

    test "get_budget!/1 returns the budget with given id" do
      budget = budget_fixture()
      assert Chronoallot.get_budget!(budget.id) == budget
    end

    test "create_budget/1 with valid data creates a budget" do
      assert {:ok, %Budget{} = budget} = Chronoallot.create_budget(@valid_attrs)
      assert budget.title == "some title"
      assert budget.week_code == "some week_code"
    end

    test "create_budget/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chronoallot.create_budget(@invalid_attrs)
    end

    test "update_budget/2 with valid data updates the budget" do
      budget = budget_fixture()
      assert {:ok, %Budget{} = budget} = Chronoallot.update_budget(budget, @update_attrs)
      assert budget.title == "some updated title"
      assert budget.week_code == "some updated week_code"
    end

    test "update_budget/2 with invalid data returns error changeset" do
      budget = budget_fixture()
      assert {:error, %Ecto.Changeset{}} = Chronoallot.update_budget(budget, @invalid_attrs)
      assert budget == Chronoallot.get_budget!(budget.id)
    end

    test "delete_budget/1 deletes the budget" do
      budget = budget_fixture()
      assert {:ok, %Budget{}} = Chronoallot.delete_budget(budget)
      assert_raise Ecto.NoResultsError, fn -> Chronoallot.get_budget!(budget.id) end
    end

    test "change_budget/1 returns a budget changeset" do
      budget = budget_fixture()
      assert %Ecto.Changeset{} = Chronoallot.change_budget(budget)
    end
  end

  describe "budget_lines" do
    alias Untitled.Chronoallot.BudgetLine

    @valid_attrs %{hours: 42}
    @update_attrs %{hours: 43}
    @invalid_attrs %{hours: nil}

    def budget_line_fixture(attrs \\ %{}) do
      {:ok, budget_line} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chronoallot.create_budget_line()

      budget_line
    end

    test "list_budget_lines/0 returns all budget_lines" do
      budget_line = budget_line_fixture()
      assert Chronoallot.list_budget_lines() == [budget_line]
    end

    test "get_budget_line!/1 returns the budget_line with given id" do
      budget_line = budget_line_fixture()
      assert Chronoallot.get_budget_line!(budget_line.id) == budget_line
    end

    test "create_budget_line/1 with valid data creates a budget_line" do
      assert {:ok, %BudgetLine{} = budget_line} = Chronoallot.create_budget_line(@valid_attrs)
      assert budget_line.hours == 42
    end

    test "create_budget_line/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chronoallot.create_budget_line(@invalid_attrs)
    end

    test "update_budget_line/2 with valid data updates the budget_line" do
      budget_line = budget_line_fixture()
      assert {:ok, %BudgetLine{} = budget_line} = Chronoallot.update_budget_line(budget_line, @update_attrs)
      assert budget_line.hours == 43
    end

    test "update_budget_line/2 with invalid data returns error changeset" do
      budget_line = budget_line_fixture()
      assert {:error, %Ecto.Changeset{}} = Chronoallot.update_budget_line(budget_line, @invalid_attrs)
      assert budget_line == Chronoallot.get_budget_line!(budget_line.id)
    end

    test "delete_budget_line/1 deletes the budget_line" do
      budget_line = budget_line_fixture()
      assert {:ok, %BudgetLine{}} = Chronoallot.delete_budget_line(budget_line)
      assert_raise Ecto.NoResultsError, fn -> Chronoallot.get_budget_line!(budget_line.id) end
    end

    test "change_budget_line/1 returns a budget_line changeset" do
      budget_line = budget_line_fixture()
      assert %Ecto.Changeset{} = Chronoallot.change_budget_line(budget_line)
    end
  end

  describe "time_logs" do
    alias Untitled.Chronoallot.TimeLogs

    @valid_attrs %{hours: 42, notes: "some notes"}
    @update_attrs %{hours: 43, notes: "some updated notes"}
    @invalid_attrs %{hours: nil, notes: nil}

    def time_logs_fixture(attrs \\ %{}) do
      {:ok, time_logs} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chronoallot.create_time_logs()

      time_logs
    end

    test "list_time_logs/0 returns all time_logs" do
      time_logs = time_logs_fixture()
      assert Chronoallot.list_time_logs() == [time_logs]
    end

    test "get_time_logs!/1 returns the time_logs with given id" do
      time_logs = time_logs_fixture()
      assert Chronoallot.get_time_logs!(time_logs.id) == time_logs
    end

    test "create_time_logs/1 with valid data creates a time_logs" do
      assert {:ok, %TimeLogs{} = time_logs} = Chronoallot.create_time_logs(@valid_attrs)
      assert time_logs.hours == 42
      assert time_logs.notes == "some notes"
    end

    test "create_time_logs/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chronoallot.create_time_logs(@invalid_attrs)
    end

    test "update_time_logs/2 with valid data updates the time_logs" do
      time_logs = time_logs_fixture()
      assert {:ok, %TimeLogs{} = time_logs} = Chronoallot.update_time_logs(time_logs, @update_attrs)
      assert time_logs.hours == 43
      assert time_logs.notes == "some updated notes"
    end

    test "update_time_logs/2 with invalid data returns error changeset" do
      time_logs = time_logs_fixture()
      assert {:error, %Ecto.Changeset{}} = Chronoallot.update_time_logs(time_logs, @invalid_attrs)
      assert time_logs == Chronoallot.get_time_logs!(time_logs.id)
    end

    test "delete_time_logs/1 deletes the time_logs" do
      time_logs = time_logs_fixture()
      assert {:ok, %TimeLogs{}} = Chronoallot.delete_time_logs(time_logs)
      assert_raise Ecto.NoResultsError, fn -> Chronoallot.get_time_logs!(time_logs.id) end
    end

    test "change_time_logs/1 returns a time_logs changeset" do
      time_logs = time_logs_fixture()
      assert %Ecto.Changeset{} = Chronoallot.change_time_logs(time_logs)
    end
  end
end
