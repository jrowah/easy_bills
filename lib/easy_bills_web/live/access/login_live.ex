defmodule EasyBillsWeb.Access.LoginLive do
  @moduledoc false

  use EasyBillsWeb, :live_view

  alias EasyBillsWeb.CommonComponents.Icons
  alias EasyBillsWeb.CoreComponents
  alias EasyBillsWeb.OnboardingLive.Shared.RegularTemplate

  def render(assigns) do
    ~H"""
    <RegularTemplate.regular>
      <div class="lg:w-[26%] mx-auto">
        <.link href={~p"/"} id="back-icon" class="flex text-purple-600 absolute mt-6 ml-[-8%]">
          <CoreComponents.back_icon /> <span class="mt-[-2px] ml-1">Back</span>
        </.link>
        <div class="flex mt-16 hidden lg:block">
          <Icons.logo_icon />
        </div>
        <.header class="text-center">
          Sign in to EasyBills
        </.header>

        <.simple_form for={@form} id="login_form" action={~p"/auth/login"} phx-update="ignore">
          <.input
            field={@form[:email]}
            type="email"
            label="Email"
            placeholder="Enter Your Email"
            required
          />
          <div class="relative">
            <.input
              field={@form[:password]}
              type="password"
              label="Password"
              placeholder="Enter Your Password"
              required
            />
            <span
              class="absolute inset-y-0 right-0 top-8 flex items-center pr-3 text-gray-700 cursor-pointer"
              phx-click="toggle-password"
            >
              <.icon name="hero-eye" />
              <.icon name="hero-eye-slash" class="hidden" />
            </span>
          </div>

          <:actions>
            <.input field={@form[:remember_me]} type="checkbox" label="Remember me" />
            <.link href={~p"/access/reset_password"} class="text-sm font-semibold text-purple-500">
              Forgot password?
            </.link>
          </:actions>
          <:actions>
            <.button phx-disable-with="Signing in..." class="w-full">
              Continue
            </.button>
          </:actions>
        </.simple_form>

        <p class="mt-4">
          Don't have an account?
          <.link navigate={~p"/access/register"} class="font-semibold text-purple-400 hover:underline">
            Sign up
          </.link>
        </p>
        <div class="w-full flex items-center justify-between py-5">
          <hr class="w-full bg-gray-400" />
          <p class="text-base font-medium leading-4 px-2.5 text-gray-400">Or</p>
          <hr class="w-full bg-gray-400" />
        </div>
        <button
          aria-label="Continue with google"
          role="button"
          class="focus:outline-none focus:ring-2 focus:ring-offset-1 focus:ring-gray-700 py-3.5 px-4 border rounded-lg border-gray-700 flex items-center w-full"
        >
          <Icons.google_icon />
          <.link
            navigate={~p"/access/login"}
            class="font-semibold text-purple-400 hover:underline mx-auto"
          >
            Login with Google
          </.link>
        </button>
      </div>
    </RegularTemplate.regular>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
