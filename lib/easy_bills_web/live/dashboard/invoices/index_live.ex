defmodule EasyBillsWeb.Dashboard.Invoices.IndexLive do
  @moduledoc false

  use EasyBillsWeb, :live_view

  alias EasyBillsWeb.CommonComponents.Icons
  alias EasyBillsWeb.CommonComponents.NavComponent

  alias EasyBills.Billing
  alias EasyBills.Billing.Invoice
  alias EasyBillsWeb.Dashboard.Components.InvoiceComponent
  alias EasyBillsWeb.InvoiceComponents.EmptyInvoice

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream_configure(:invoices, dom_id: &"invoice-#{&1.id}")
     |> stream(:invoices, Billing.list_invoices())}
  end

  @impl Phoenix.LiveView
  def handle_event("toggle_dark_mode", _value, socket) do
    {:noreply, push_event(socket, "toggle_dark_mode", %{})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Invoice")
    |> assign(:invoice, Billing.get_invoice!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Invoice")
    |> assign(:invoice, %Invoice{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Invoices")
    |> assign(:invoice, nil)
  end

  @impl true
  def handle_info({EasyBillsWeb.InvoiceLive.FormComponent, {:saved, invoice}}, socket) do
    {:noreply, stream_insert(socket, :invoices, invoice)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    invoice = Billing.get_invoice!(id)
    {:ok, _} = Billing.delete_invoice(invoice)

    {:noreply, stream_delete(socket, :invoices, invoice)}
  end
end
