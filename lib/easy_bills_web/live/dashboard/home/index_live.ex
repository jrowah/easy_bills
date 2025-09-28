defmodule EasyBillsWeb.Dashboard.Home.IndexLive do
  @moduledoc """
  Dashboard
  """
  use EasyBillsWeb, :live_view

  alias EasyBills.Accounts
  alias EasyBillsWeb.CommonComponents.Icons
  alias EasyBillsWeb.CommonComponents.NavComponent

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(:avatar_selected?, false)
     |> allow_upload(:avatar_url,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1
     )}
  end

  @impl Phoenix.LiveView
  def handle_event("toggle_dark_mode", _value, socket) do
    {:noreply, push_event(socket, "toggle_dark_mode", %{})}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("update_address", %{"user" => address_params}, socket) do
    user = socket.assigns.current_user

    case Accounts.add_user_address(user, address_params) do
      {:ok, _business_address} ->
        {:noreply,
         socket
         |> assign(:pending_business_address, false)
         |> put_flash(:info, "Address updated successfully.")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_info({:added_avatar, _params}, socket) do
    # update the list of cards in the socket
    {:noreply,
     assign(socket, :pending_avatar_upload, false) |> assign(:pending_business_address, true)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
