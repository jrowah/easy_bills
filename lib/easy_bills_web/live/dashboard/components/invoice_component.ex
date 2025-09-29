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
      class="flex mx-auto justify-around space-y-2 items-center w-1/2 rounded-lg bg-white shadow-lg py-2"
      data-invoice-id={@invoice.id}
    >
      <li class="text-lg font-bold mt-2">
        <span class="text-gray-400">#</span><%= transform_id(@invoice.id) %>
      </li>
      <li class="text-sm font-medium mt-2 text-gray-400">
        <span>Due on </span><%= @invoice.due_at %>
      </li>
      <li class="text-lg font-bold mt-2 text-gray-400">
        <%= @invoice.client_name %>
      </li>
      <li class="text-lg font-bold mt-2">
        <%!-- <span>£ </span><%= @invoice.amount %> --%>
      </li>
      <li class="text-sm font-medium mt-2">
        <%!-- <%= @invoice.status %> --%>
      </li>
      <li class="text-sm font-medium mt-2 cursor-pointer">
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
end
