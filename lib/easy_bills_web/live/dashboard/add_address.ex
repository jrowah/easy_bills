defmodule EasyBillsWeb.Dashboard.AddAddress do
  @moduledoc false
  use EasyBillsWeb, :live_component

  alias EasyBills.Accounts.User
  alias EasyBillsWeb.CommonComponents.Icons
  alias EasyBillsWeb.CoreComponents
  alias EasyBillsWeb.OnboardingLive.Shared.RegularTemplate

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    socket = assign(socket, assigns)
    user = socket.assigns.current_user
    changeset = User.registration_changeset(user, %{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <RegularTemplate.regular>
        <div class="md:w-1/3 mx-auto mt-16">
          <.link
            href={~p"/welcome"}
            id="back-icon"
            class="flex text-purple-600 absolute mt-[-6%] lg:mt-[-2%] lg:ml-[-8%]"
          >
            <CoreComponents.back_icon /> <span class="mt-[-2px] ml-1">Back</span>
          </.link>
          <div class="flex mb-4 hidden lg:block">
            <Icons.logo_icon />
          </div>
          <h3 class="text-center font-bold text-2xl">
            Enter your business address details:
          </h3>
          <.simple_form
            for={@form}
            id="address_form"
            phx-change="validate"
            phx-submit="update_address"
            phx-trigger-action={@trigger_submit}
            action={~p"/address"}
            method="post"
          >
            <.error :if={@check_errors}>
              Oops, something went wrong! Please check the errors below.
            </.error>

            <div class=" md:flex md:space-x-3">
              <div class="md:w-1/2 text-gray-800">
                <.input
                  field={@form[:country]}
                  type="select"
                  options={country_options()}
                  label="Country"
                  required
                />
              </div>
              <.input field={@form[:city]} type="text" label="City" required />
            </div>
            <.input field={@form[:street_address]} type="text" label="Street Address" required />
            <.input field={@form[:postal_code]} type="text" label="Postal Address" required />
            <.input field={@form[:phone_number]} type="tel" label="Phone Number" required />

            <div class="flex place-content-center text-lg font-semibold">
              <button
                type="submit"
                phx-disable-with="Saving..."
                class="px-8 py-1 flex items-center w-40 justify-center rounded-full text-[#FFFFFF] bg-[#7C5DFA]"
              >
                Save
              </button>
            </div>
          </.simple_form>
        </div>
      </RegularTemplate.regular>
    </div>
    """
  end

  defp country_options do
    Enum.map(Countries.all(), & &1.name) |> Enum.sort()
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
