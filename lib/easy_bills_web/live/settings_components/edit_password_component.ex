defmodule EasyBillsWeb.SettingsComponents.EditPasswordComponent do
  @moduledoc false

  use EasyBillsWeb, :live_component

  alias EasyBillsWeb.OnboardingLive.Shared.DeleteAccountComponent
  alias EasyBillsWeb.OnboardingLive.Shared.NewPasswordInputComponent

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
      <div class="flex">
        <img
          src={@current_user.avatar_url}
          alt={"#{@current_user.username}'s" <> " Avatar"}
          class="rounded-full h-20 w-20 mb-4"
        />
        <h1 class="flex items-center font-bold text-lg ml-4">
          <%= @current_user.username <> " " <> @current_user.name %> / Password
        </h1>
      </div>
      <h1><%= @title %></h1>
      <div>
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/auth/login?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <.input
            field={@password_form[:email]}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Old password"
            id="current_password_for_password"
            placeholder="Enter your old password"
            value={@current_password}
            required
          />
          <div class="relative">
            <NewPasswordInputComponent.new_password_input form={@password_form} label="New password" />
          </div>
          <:actions>
            <div
              id="delete-account"
              class="text-rose-500 cursor-pointer"
              phx-click={show_modal("delete-account-modal")}
            >
              Delete Account
            </div>
            <.button phx-disable-with="Changing...">Save changes</.button>
          </:actions>
        </.simple_form>
        <.modal id="delete-account-modal">
          <.live_component
            module={DeleteAccountComponent}
            id="delete_account_component"
            current_user={@current_user}
            title="Delete Account"
            email_form={@email_form}
            trigger_submit={@trigger_submit}
          />
        </.modal>
      </div>
    </div>
    """
  end
end
