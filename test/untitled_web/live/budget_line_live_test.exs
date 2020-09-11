defmodule UntitledWeb.BudgetLineLiveTest do
  use UntitledWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Untitled.Chronoallot

  @create_attrs %{hours: 42}
  @update_attrs %{hours: 43}
  @invalid_attrs %{hours: nil}

  defp fixture(:budget_line) do
    {:ok, budget_line} = Chronoallot.create_budget_line(@create_attrs)
    budget_line
  end

  defp create_budget_line(_) do
    budget_line = fixture(:budget_line)
    %{budget_line: budget_line}
  end

  describe "Index" do
    setup [:create_budget_line]

    test "lists all budget_lines", %{conn: conn, budget_line: budget_line} do
      {:ok, _index_live, html} = live(conn, Routes.budget_line_index_path(conn, :index))

      assert html =~ "Listing Budget lines"
    end

    test "saves new budget_line", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.budget_line_index_path(conn, :index))

      assert index_live |> element("a", "New Budget line") |> render_click() =~
               "New Budget line"

      assert_patch(index_live, Routes.budget_line_index_path(conn, :new))

      assert index_live
             |> form("#budget_line-form", budget_line: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#budget_line-form", budget_line: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.budget_line_index_path(conn, :index))

      assert html =~ "Budget line created successfully"
    end

    test "updates budget_line in listing", %{conn: conn, budget_line: budget_line} do
      {:ok, index_live, _html} = live(conn, Routes.budget_line_index_path(conn, :index))

      assert index_live |> element("#budget_line-#{budget_line.id} a", "Edit") |> render_click() =~
               "Edit Budget line"

      assert_patch(index_live, Routes.budget_line_index_path(conn, :edit, budget_line))

      assert index_live
             |> form("#budget_line-form", budget_line: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#budget_line-form", budget_line: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.budget_line_index_path(conn, :index))

      assert html =~ "Budget line updated successfully"
    end

    test "deletes budget_line in listing", %{conn: conn, budget_line: budget_line} do
      {:ok, index_live, _html} = live(conn, Routes.budget_line_index_path(conn, :index))

      assert index_live |> element("#budget_line-#{budget_line.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#budget_line-#{budget_line.id}")
    end
  end

  describe "Show" do
    setup [:create_budget_line]

    test "displays budget_line", %{conn: conn, budget_line: budget_line} do
      {:ok, _show_live, html} = live(conn, Routes.budget_line_show_path(conn, :show, budget_line))

      assert html =~ "Show Budget line"
    end

    test "updates budget_line within modal", %{conn: conn, budget_line: budget_line} do
      {:ok, show_live, _html} = live(conn, Routes.budget_line_show_path(conn, :show, budget_line))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Budget line"

      assert_patch(show_live, Routes.budget_line_show_path(conn, :edit, budget_line))

      assert show_live
             |> form("#budget_line-form", budget_line: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#budget_line-form", budget_line: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.budget_line_show_path(conn, :show, budget_line))

      assert html =~ "Budget line updated successfully"
    end
  end
end
