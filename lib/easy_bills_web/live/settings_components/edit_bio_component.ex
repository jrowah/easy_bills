defmodule EasyBillsWeb.SettingsComponents.EditBioComponent do
  @moduledoc false

  use EasyBillsWeb, :live_component

  alias EasyBillsWeb.OnboardingLive.Shared.DeleteAccountComponent

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
        <h1 class="flex items-center font-bold text-lg ml-4 ">
          <%= @current_user.username <> " " <> @current_user.name %> / Profile Information
        </h1>
      </div>
      <h1><%= @title %></h1>
      <div>
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <div class="grid grid-cols-2 gap-x-4">
            <.input field={@email_form[:name]} type="text" label="Name" required />
            <.input field={@email_form[:username]} type="text" label="Username" required />
          </div>
          <.input field={@email_form[:email]} type="email" label="Email" required />
          <div class="grid grid-cols-2 gap-x-4">
            <.input
              field={@address_form[:country]}
              type="select"
              options={country_options()}
              label="Country"
            />
            <.input field={@address_form[:city]} type="text" label="City" />
            <.input field={@address_form[:street_address]} type="text" label="Street Address" />
            <.input field={@address_form[:postal_code]} type="text" label="Postal Code" />
          </div>
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label="Current password"
            value={@email_form_current_password}
            required
          />
          <:actions>
            <div
              id="delete-account"
              class="text-rose-500 cursor-pointer"
              phx-click={show_modal("delete-account-modal")}
            >
              Delete Account
            </div>
            <.button phx-disable-with="Changing...">Save Changes</.button>
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

  defp country_options do
    Enum.map(Countries.all(), & &1.name) |> Enum.sort()
  end
end
