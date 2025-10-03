defmodule EasyBillsWeb.Dashboard.Components.InvoiceComponent do
  @moduledoc false

  use EasyBillsWeb, :live_component
  # alias EasyBills.Billing.Invoice
  # alias EasyBillsWeb.CommonComponents.Icons
  # alias Phoenix.LiveView.JS

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <ul
      id={"invoice-#{@invoice.id}"}
      class="flex mx-auto justify-around space-y-2 text-gray-400 text-sm items-start w-1/2 rounded-lg bg-white shadow-lg py-2"
      data-invoice-id={@invoice.id}
    >
      <li class="font-bold my-auto text-black">
        <span class="text-gray-400">#</span><%= transform_id(@invoice.id) %>
      </li>
      <li class="font-medium my-auto text-gray-400">
        <span>Due </span><%= @invoice.due_at %>
      </li>
      <li class="font-bold my-auto text-left text-gray-400">
        <%= @invoice.client_name %>
      </li>
      <li class="font-bold text-black">
        <span>£ <%= amount_due(@invoice) %></span>
      </li>
      <li class="font-bold">
        <span class={[
          "p-2 bg-gray-200",
          @invoice.status == :paid && "text-green-400",
          @invoice.status == :draft && "text-black",
          @invoice.status == :pending && "text-orange-400",
          @invoice.status == :cancelled && "text-red-400",
          "rounded-lg"
        ]}>
          <span class={[
            "h-2 w-2 rounded-full inline-block",
            @invoice.status == :paid && "bg-green-400",
            @invoice.status == :pending && "bg-orange-400",
            @invoice.status == :draft && "bg-black",
            @invoice.status == :cancelled && "bg-red-400"
          ]}>
          </span> <%= @invoice.status %>
        </span>
      </li>
      <li class="font-medium mt-2 cursor-pointer">
        <.link navigate={~p"/dashboard/invoices/#{@invoice}"}>
          <.icon name="hero-chevron-right" class="h-3 w-3" />
        </.link>
      </li>
    </ul>
    """
  end

  defp transform_id(id) do
    id
    |> String.upcase()
    |> String.slice(0, 6)
  end

  defp amount_due(invoice) do
    case invoice.items do
      [] ->
        0.00

      items ->
        items
        |> Enum.map(fn item -> item.quantity * item.unit_price end)
        |> Enum.reduce(fn item_total, acc -> item_total + acc end)
    end
  end
end
