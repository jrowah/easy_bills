defmodule EasyBillsWeb.OnboardingLive.UserRegistration.New do
  @moduledoc false

  use EasyBillsWeb, :live_component

  alias EasyBillsWeb.CommonComponents.Icons
  alias EasyBillsWeb.CoreComponents
  alias EasyBillsWeb.OnboardingLive.Shared.NewPasswordInputComponent
  alias EasyBillsWeb.OnboardingLive.Shared.RegularTemplate

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="text-gray-900 dark:text-white bg-white dark:bg-gray_secondary antialiased">
      <RegularTemplate.regular socket={@socket}>
        <div class="mx-auto mt-16">
          <.link
            href={~p"/"}
            id="back-icon"
            class="flex text-purple-600 dark:text-purple-300 absolute mt-[-6%] lg:mt-[-2%] lg:ml-[-8%]"
          >
            <CoreComponents.back_icon /> <span class="mt-[-2px] ml-1">Back</span>
          </.link>
          <div class="flex mb-4 hidden lg:block">
            <Icons.logo_icon />
          </div>
          <h3 class="text-center font-bold text-3xl">
            Create an account
          </h3>
          <p>Begin creating invoices for free!</p>

          <.simple_form
            for={@form}
            id="registration_form"
            phx-submit="save"
            phx-change="validate"
            phx-trigger-action={@trigger_submit}
            action={~p"/auth/login?_action=registered"}
            method="post"
          >
            <.error :if={@check_errors}>
              Oops, something went wrong! Please check the errors below.
            </.error>

            <div class="lg:flex justify-between">
              <div class="sm:mb-4 lg:mb-0">
                <.input
                  field={@form[:name]}
                  type="text"
                  label="Name"
                  placeholder="Enter Your Name"
                  required
                />
              </div>
              <.input
                field={@form[:username]}
                type="text"
                label="Username"
                placeholder="Enter Your Username"
                required
              />
            </div>
            <.input
              field={@form[:email]}
              type="email"
              label="Email"
              placeholder="Enter Your Email"
              required
            />
            <div class="relative">
              <NewPasswordInputComponent.new_password_input form={@form} label="Password" />
            </div>

            <label class="flex flex-col left-0 flex-row-reverse items-center justify-between">
              <span class="flex space-x-2 flex-row-reverse">
                <.input
                  field={@form[:policy_and_terms]}
                  type="checkbox"
                  label="I agree with EasyBills' Terms of Use and Privacy Policy"
                />
              </span>
            </label>

            <:actions>
              <.button phx-disable-with="Creating account..." class="w-full">
                Sign Up
              </.button>
            </:actions>
          </.simple_form>
          <p class="mt-6 ml-[20%]">
            Already have an account?
            <.link navigate={~p"/access/login"} class="font-semibold text-purple-400 hover:underline">
              Sign in
            </.link>
          </p>
        </div>
      </RegularTemplate.regular>
    </div>
    """
  end
end
