defmodule EasyBillsWeb.Dashboard.Expenses.IndexLive do
  use EasyBillsWeb, :live_view

  # alias EasyBills.Accounts
  # alias EasyBills.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
