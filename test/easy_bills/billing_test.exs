defmodule EasyBills.BillingTest do
  use EasyBills.DataCase

  alias EasyBills.Billing

  describe "invoices" do
    alias EasyBills.Billing.Invoice

    import EasyBills.BillingFixtures

    @invalid_attrs %{
      amount: nil,
      client: nil,
      description: nil,
      due_at: nil,
      from: nil,
      status: nil
    }

    test "list_invoices/0 returns all invoices" do
      invoice = invoice_fixture()
      assert Billing.list_invoices() == [invoice]
    end

    test "get_invoice!/1 returns the invoice with given id" do
      invoice = invoice_fixture()
      assert Billing.get_invoice!(invoice.id) == invoice
    end

    test "create_invoice/1 with valid data creates a invoice" do
      valid_attrs = %{
        amount: "some amount",
        client: %{},
        description: "some description",
        due_at: ~D[2024-06-14],
        from: %{},
        status: "some status"
      }

      assert {:ok, %Invoice{} = invoice} = Billing.create_invoice(valid_attrs)
      assert invoice.amount == "some amount"
      assert invoice.client == %{}
      assert invoice.description == "some description"
      assert invoice.due_at == ~D[2024-06-14]
      assert invoice.from == %{}
      assert invoice.status == "some status"
    end

    test "create_invoice/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Billing.create_invoice(@invalid_attrs)
    end

    test "update_invoice/2 with valid data updates the invoice" do
      invoice = invoice_fixture()

      update_attrs = %{
        amount: "some updated amount",
        client: %{},
        description: "some updated description",
        due_at: ~D[2024-06-15],
        from: %{},
        status: "some updated status"
      }

      assert {:ok, %Invoice{} = invoice} = Billing.update_invoice(invoice, update_attrs)
      assert invoice.amount == "some updated amount"
      assert invoice.client == %{}
      assert invoice.description == "some updated description"
      assert invoice.due_at == ~D[2024-06-15]
      assert invoice.from == %{}
      assert invoice.status == "some updated status"
    end

    test "update_invoice/2 with invalid data returns error changeset" do
      invoice = invoice_fixture()
      assert {:error, %Ecto.Changeset{}} = Billing.update_invoice(invoice, @invalid_attrs)
      assert invoice == Billing.get_invoice!(invoice.id)
    end

    test "delete_invoice/1 deletes the invoice" do
      invoice = invoice_fixture()
      assert {:ok, %Invoice{}} = Billing.delete_invoice(invoice)
      assert_raise Ecto.NoResultsError, fn -> Billing.get_invoice!(invoice.id) end
    end

    test "change_invoice/1 returns a invoice changeset" do
      invoice = invoice_fixture()
      assert %Ecto.Changeset{} = Billing.change_invoice(invoice)
    end
  end
end
