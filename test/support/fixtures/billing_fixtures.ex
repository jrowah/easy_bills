defmodule EasyBills.BillingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EasyBills.Billing` context.
  """

  @doc """
  Generate a invoice.
  """
  def invoice_fixture(attrs \\ %{}) do
    {:ok, invoice} =
      attrs
      |> Enum.into(%{
        amount: "some amount",
        client: %{},
        description: "some description",
        due_at: ~D[2024-06-14],
        from: %{},
        status: "some status"
      })
      |> EasyBills.Billing.create_invoice()

    invoice
  end
end
