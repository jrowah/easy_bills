defmodule EasyBillsWeb.InvoiceLive.FormComponent do
  use EasyBillsWeb, :live_component

  alias EasyBills.Billing

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Bill To</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        class="space-y-2"
        id="invoice-form"
        phx-target={@myself}
        phx-change="validate"
      >
        <div class="grid grid-cols-2 gap-4">
          <.input field={@form[:client_name]} type="text" label="Client name" />
          <.input field={@form[:client_email]} type="email" label="Client email" />
        </div>
        <.input field={@form[:client_street_address]} type="text" label="Client address" />
        <div class="grid grid-cols-3 gap-4">
          <.input field={@form[:client_city]} type="text" label="City" />
          <.input field={@form[:client_postal_code]} type="text" label="Postal Code" />
          <.input field={@form[:client_country]} type="text" label="Country" />
        </div>
        <div class="grid grid-cols-2 gap-4">
          <.input field={@form[:due_at]} type="date" label="Invoice Date" />
          <.input field={@form[:terms]} type="text" label="Payment Terms" />
        </div>
        <.input field={@form[:description]} type="text" label="Project Description" />
        <div class="space-y-2 max-h-[300px]" id="items">
          <h6>Item List</h6>
          <div class="">
            <table class="w-full">
              <thead class="text-sm text-left leading-6 text-zinc-500">
                <tr>
                  <th>Item Name</th>
                  <th>Quantity</th>
                  <th>Unit Price</th>
                  <th>Total</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <.inputs_for :let={item_form} field={@form[:items]}>
                  <tr>
                    <td><.input field={item_form[:item_name]} type="text" /></td>
                    <td><.input field={item_form[:quantity]} type="number" step="1" /></td>
                    <td><.input field={item_form[:unit_price]} type="number" step="0.01" /></td>
                    <td class="text-center">
                      <% total(item_form) %> £<%= :erlang.float_to_binary(total(item_form) * 1.0,
                        decimals: 2
                      ) %>
                    </td>
                    <td>
                      <button
                        type="button"
                        phx-click="remove_item"
                        phx-target={@myself}
                        phx-value-index={item_form.index}
                        class="cursor-pointer text-gray-500"
                      >
                        <.icon name="hero-trash-solid" />
                      </button>
                    </td>
                  </tr>
                </.inputs_for>
              </tbody>
            </table>
          </div>
        </div>
        <div
          phx-click="add_item"
          phx-target={@myself}
          class="cursor-pointer bg-gray-200 p-2 text-center rounded-2xl text-sm"
        >
          <span>&plus; Add New Item</span>
        </div>
        <div class="flex justify-between">
          <input
            class="cursor-pointer bg-gray-200 py-3 px-4 text-center rounded-full"
            type="reset"
            value="Discard"
          />
          <div class="flex items-center justify-end">
            <.button
              phx-click="save_draft"
              phx-target={@myself}
              phx-disable-with="Saving..."
              class="py-3 px-4 mr-2"
              type="button"
            >
              Save as Draft
            </.button>
            <.button
              phx-click="save_and_send"
              phx-target={@myself}
              phx-disable-with="Saving..."
              class="py-3 px-4"
              type="button"
            >
              Save and Send
            </.button>
          </div>
        </div>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{invoice: invoice} = assigns, socket) do
    changeset = Billing.change_invoice(invoice)

    # Ensure we have at least one item for new invoices
    changeset =
      if invoice.items == [] or is_nil(invoice.items) do
        Ecto.Changeset.put_embed(changeset, :items, [
          %{item_name: "", quantity: 1, unit_price: 0.00}
        ])
      else
        changeset
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"invoice" => invoice_params}, socket) do
    changeset =
      socket.assigns.invoice
      |> Billing.change_invoice(invoice_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save_draft", _params, socket) do
    # Get the current form data and process items
    form_data =
      socket.assigns.form.params
      |> process_items_data()

    save_invoice_as_draft(socket, socket.assigns.action, form_data)
  end

  def handle_event("save_and_send", _params, socket) do
    # Get the current form data and process items
    form_data =
      socket.assigns.form.params
      |> process_items_data()

    save_and_send_invoice(socket, socket.assigns.action, form_data)
  end

  def handle_event("add_item", _params, socket) do
    existing_items = Ecto.Changeset.get_embed(socket.assigns.form.source, :items, :struct) || []
    new_item = %{item_name: "", quantity: 1, unit_price: 0.00}

    changeset =
      socket.assigns.form.source
      |> Ecto.Changeset.put_embed(:items, existing_items ++ [new_item])

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("remove_item", %{"index" => index}, socket) do
    index = String.to_integer(index)
    existing_items = Ecto.Changeset.get_embed(socket.assigns.form.source, :items, :struct) || []
    updated_items = List.delete_at(existing_items, index)

    changeset =
      socket.assigns.form.source
      |> Ecto.Changeset.put_embed(:items, updated_items)

    {:noreply, assign_form(socket, changeset)}
  end

  defp save_invoice_as_draft(socket, :edit, invoice_params) do
    # Add draft status to params (as atom)
    draft_params = Map.put(invoice_params, "status", :draft)

    case Billing.update_invoice(socket.assigns.invoice, draft_params) do
      {:ok, invoice} ->
        notify_parent({:saved, invoice})

        {:noreply,
         socket
         |> put_flash(:info, "Invoice saved as draft")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_invoice_as_draft(socket, :new, invoice_params) do
    # Add draft status to params
    draft_params = Map.put(invoice_params, "status", "draft")

    case Billing.create_invoice(draft_params) do
      {:ok, invoice} ->
        notify_parent({:saved, invoice})

        {:noreply,
         socket
         |> put_flash(:info, "Invoice saved as draft")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_and_send_invoice(socket, :edit, invoice_params) do
    # Add sent status to params (as atom)
    sent_params = Map.put(invoice_params, "status", :pending)

    case Billing.update_invoice(socket.assigns.invoice, sent_params) do
      {:ok, invoice} ->
        # Here you could add logic to actually send the invoice (email, etc.)
        notify_parent({:saved, invoice})

        {:noreply,
         socket
         |> put_flash(:info, "Invoice saved and sent successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_and_send_invoice(socket, :new, invoice_params) do
    # Add sent status to params (as atom)
    sent_params = Map.put(invoice_params, "status", :pending)

    case Billing.create_invoice(sent_params) do
      {:ok, invoice} ->
        # Here you could add logic to actually send the invoice (email, etc.)
        notify_parent({:saved, invoice})

        {:noreply,
         socket
         |> put_flash(:info, "Invoice created and sent successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp process_items_data(params) do
    case Map.get(params, "items") do
      items when is_map(items) ->
        # Convert map of items to list, filtering out empty items
        items_list =
          items
          |> Enum.map(fn {_key, item_data} ->
            # Remove the _persistent_id field that Phoenix adds
            Map.drop(item_data, ["_persistent_id"])
          end)
          |> Enum.reject(fn item ->
            # Reject items where all required fields are empty or invalid
            empty_name = is_nil(item["item_name"]) or item["item_name"] == ""

            zero_quantity =
              is_nil(item["quantity"]) or item["quantity"] == "" or item["quantity"] == "0"

            zero_price =
              is_nil(item["unit_price"]) or item["unit_price"] == "" or item["unit_price"] == "0"

            empty_name and zero_quantity and zero_price
          end)

        Map.put(params, "items", items_list)

      items when is_list(items) ->
        # Items already in correct format
        params

      _ ->
        # No items or invalid format, set empty list
        Map.put(params, "items", [])
    end
  end

  defp total(item_form) do
    quantity =
      case item_form[:quantity].value do
        val when is_number(val) ->
          val

        val when is_binary(val) and val != "" ->
          case Float.parse(val) do
            {num, _} -> num
            :error -> 0
          end

        _ ->
          0
      end

    unit_price =
      case item_form[:unit_price].value do
        val when is_number(val) ->
          val

        val when is_binary(val) and val != "" ->
          case Float.parse(val) do
            {num, _} -> num
            :error -> 0
          end

        _ ->
          0
      end

    total = quantity * unit_price
    total
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
