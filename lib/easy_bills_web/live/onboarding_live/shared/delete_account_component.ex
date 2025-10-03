defmodule EasyBillsWeb.OnboardingLive.Shared.DeleteAccountComponent do
  @moduledoc false

  use EasyBillsWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="font-bold text-lg mb-8"><%= @title %></h1>
      <h4 class="font-bold mb-4">
        Would you like to delete your EasyBills account<span class="text-purple-500">(@<%= truncate_email(@current_user.email) %>)</span>?
      </h4>
      <p>
        Deleting your account will remove all your content and data associated with your EasyBills profile. To confirm the permanent deletion of <%= @current_user.email %> please type your email address ("<%= @current_user.email %>") below.
      </p>
      <div>
        <.simple_form
          for={@email_form}
          id="delete_account_form"
          phx-submit="delete_account"
          phx-change="validate_delete_account"
          phx-trigger-action={@trigger_submit}
        >
          <.input
            field={@email_form[:email]}
            name="email"
            id="email_for_delete_account"
            type="email"
            label="Email"
            required
          />

          <:actions>
            <.button phx-disable-with="Deleting..." class="w-16" disabled>
              Ok
            </.button>
            <div
              phx-click={JS.exec("data-cancel", to: "#delete-account-modal")}
              class="rounded-full border border-purple-700 text-purple-700 px-4 py-1 cursor-pointer"
            >
              Cancel
            </div>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  defp truncate_email(email) do
    [local_part, _domain] = String.split(email, "@")
    local_part
  end
end
