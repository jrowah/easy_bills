defmodule EasyBillsWeb.Dashboard.Components.EmptyInvoice do
  @moduledoc false

  use EasyBillsWeb, :html

  alias EasyBillsWeb.CommonComponents.Icons

  def empty_inbox(assigns) do
    ~H"""
    <div class="text-gray-900 dark:text-white bg-white dark:bg-gray_secondary antialiased flex flex-col items-center ml-[23%] w-1/2 h-[70vh] mt-[8%] space-y-6">
      <Icons.no_invoices_icon />
      <h3 class="font-bold">There is nothing here</h3>
      <p class="w-1/2">Create an invoice by clicking the New Invoice button and get started</p>
    </div>
    """
  end
end
