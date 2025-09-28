defmodule EasyBillsWeb.Dashboard.Invoices.IndexLive do
  @moduledoc false

  use EasyBillsWeb, :live_view

  alias EasyBillsWeb.CommonComponents.Icons
  alias EasyBillsWeb.CommonComponents.NavComponent

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("toggle_dark_mode", _value, socket) do
    {:noreply, push_event(socket, "toggle_dark_mode", %{})}
  end
end
