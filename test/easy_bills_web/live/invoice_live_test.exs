defmodule EasyBillsWeb.InvoiceLiveTest do
  use EasyBillsWeb.ConnCase

  import Phoenix.LiveViewTest
  alias EasyBillsWeb.AccountsFixtures
  import EasyBills.BillingFixtures

  @create_attrs %{
    amount: "some amount",
    client: %{},
    description: "some description",
    due_at: "2024-06-14",
    from: %{},
    status: "some status"
  }
  @update_attrs %{
    amount: "some updated amount",
    client: %{},
    description: "some updated description",
    due_at: "2024-06-15",
    from: %{},
    status: "some updated status"
  }
  @invalid_attrs %{
    amount: nil,
    client: nil,
    description: nil,
    due_at: nil,
    from: nil,
    status: nil
  }

  defp create_invoice(_) do
    invoice = invoice_fixture()
    %{invoice: invoice}
  end

  describe "Index" do
    setup [:create_invoice]

    test "lists all invoices", %{conn: conn, invoice: invoice} do
      #
      {:ok, _index_live, html} = conn |> log_in_user(user_fixture()) |> live(~p"/invoices")

      assert html =~ "Invoices"
      assert html =~ invoice.amount
    end

    test "saves new invoice", %{conn: conn} do
      #
      {:ok, index_live, _html} = live(conn, ~p"/invoices")

      assert index_live |> element("a", "New Invoice") |> render_click() =~
               "New Invoice"

      assert_patch(index_live, ~p"/invoices/new")

      assert index_live
             |> form("#invoice-form", invoice: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#invoice-form", invoice: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/invoices")

      html = render(index_live)
      assert html =~ "Invoice created successfully"
      assert html =~ "some amount"
    end

    test "updates invoice in listing", %{conn: conn, invoice: invoice} do
      #
      {:ok, index_live, _html} = live(conn, ~p"/invoices")

      assert index_live |> element("#invoices-#{invoice.id} a", "Edit") |> render_click() =~
               "Edit Invoice"

      assert_patch(index_live, ~p"/invoices/#{invoice}/edit")

      assert index_live
             |> form("#invoice-form", invoice: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#invoice-form", invoice: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/invoices")

      html = render(index_live)
      assert html =~ "Invoice updated successfully"
      assert html =~ "some updated amount"
    end

    test "deletes invoice in listing", %{conn: conn, invoice: invoice} do
      #
      {:ok, index_live, _html} = live(conn, ~p"/invoices")

      assert index_live |> element("#invoices-#{invoice.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#invoices-#{invoice.id}")
    end
  end

  describe "Show" do
    setup [:create_invoice]

    setup %{conn: conn} do
      password = valid_user_password()
      user = user_fixture(%{password: password})
      %{conn: log_in_user(conn, user), user: user, password: password}
    end

    test "displays invoice", %{conn: conn, invoice: invoice} do
      #
      {:ok, _show_live, html} = live(conn, ~p"/invoices/#{invoice}")

      assert html =~ "Show Invoice"
      assert html =~ invoice.amount
    end

    test "updates invoice within modal", %{conn: conn, invoice: invoice} do
      #
      {:ok, show_live, _html} = live(conn, ~p"/invoices/#{invoice}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Invoice"

      assert_patch(show_live, ~p"/invoices/#{invoice}/show/edit")

      assert show_live
             |> form("#invoice-form", invoice: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#invoice-form", invoice: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/invoices/#{invoice}")

      html = render(show_live)
      assert html =~ "Invoice updated successfully"
      assert html =~ "some updated amount"
    end
  end
end
