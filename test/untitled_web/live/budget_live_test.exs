defmodule UntitledWeb.BudgetLiveTest do
  use UntitledWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Untitled.Chronoallot

  @create_attrs %{title: "some title", week_code: "some week_code"}
  @update_attrs %{title: "some updated title", week_code: "some updated week_code"}
  @invalid_attrs %{title: nil, week_code: nil}

  defp fixture(:budget) do
    {:ok, budget} = Chronoallot.create_budget(@create_attrs)
    budget
  end

  defp create_budget(_) do
    budget = fixture(:budget)
    %{budget: budget}
  end

  describe "Index" do
    setup [:create_budget]

    test "lists all budgets", %{conn: conn, budget: budget} do
      {:ok, _index_live, html} = live(conn, Routes.budget_index_path(conn, :index))

      assert html =~ "Listing Budgets"
      assert html =~ budget.title
    end

    test "saves new budget", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.budget_index_path(conn, :index))

      assert index_live |> element("a", "New Budget") |> render_click() =~
               "New Budget"

      assert_patch(index_live, Routes.budget_index_path(conn, :new))

      assert index_live
             |> form("#budget-form", budget: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#budget-form", budget: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.budget_index_path(conn, :index))

      assert html =~ "Budget created successfully"
      assert html =~ "some title"
    end

    test "updates budget in listing", %{conn: conn, budget: budget} do
      {:ok, index_live, _html} = live(conn, Routes.budget_index_path(conn, :index))

      assert index_live |> element("#budget-#{budget.id} a", "Edit") |> render_click() =~
               "Edit Budget"

      assert_patch(index_live, Routes.budget_index_path(conn, :edit, budget))

      assert index_live
             |> form("#budget-form", budget: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#budget-form", budget: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.budget_index_path(conn, :index))

      assert html =~ "Budget updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes budget in listing", %{conn: conn, budget: budget} do
      {:ok, index_live, _html} = live(conn, Routes.budget_index_path(conn, :index))

      assert index_live |> element("#budget-#{budget.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#budget-#{budget.id}")
    end
  end

  describe "Show" do
    setup [:create_budget]

    test "displays budget", %{conn: conn, budget: budget} do
      {:ok, _show_live, html} = live(conn, Routes.budget_show_path(conn, :show, budget))

      assert html =~ "Show Budget"
      assert html =~ budget.title
    end

    test "updates budget within modal", %{conn: conn, budget: budget} do
      {:ok, show_live, _html} = live(conn, Routes.budget_show_path(conn, :show, budget))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Budget"

      assert_patch(show_live, Routes.budget_show_path(conn, :edit, budget))

      assert show_live
             |> form("#budget-form", budget: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#budget-form", budget: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.budget_show_path(conn, :show, budget))

      assert html =~ "Budget updated successfully"
      assert html =~ "some updated title"
    end
  end
end
