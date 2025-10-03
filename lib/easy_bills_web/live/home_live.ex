defmodule EasyBillsWeb.HomeLive do
  @moduledoc false

  use EasyBillsWeb, :live_view

  alias EasyBillsWeb.CommonComponents.Icons
  alias EasyBillsWeb.OnboardingLive.Shared.RegularTemplate

  def render(assigns) do
    ~H"""
    <RegularTemplate.regular>
      <div class="mx-auto mt-16 items-center justify-center mx-w-md">
        <div class="flex mb-4 hidden lg:block">
          <Icons.logo_icon />
        </div>
        <h3 class="text-center font-bold text-3xl">
          Sign in to EasyBills.
        </h3>
        <div class="mt-10 grid space-y-8 mx-w-sm">
          <button
            aria-label="Continue with google"
            role="button"
            class="group h-12 px-6 border-2 border-gray-300 rounded-full transition duration-300
    hover:border-blue-400 focus:bg-blue-50 active:bg-blue-100 mx-w-sm"
          >
            <div class="relative flex items-center space-x-4 mx-w-sm justify-center">
              <Icons.google_icon />
              <p class="text-base font-medium ml-4 text-gray-700">Continue with Google</p>
            </div>
          </button>
          <button class="group h-12 px-6 border-2 border-gray-300 rounded-full transition duration-300
    hover:border-blue-400 focus:bg-blue-50 active:bg-blue-100">
            <div class="relative flex items-center space-x-4 justify-center">
              <Icons.email_icon />
              <.link
                href={~p"/access/login"}
                class="text-md leading-6 text-gray-700 font-semibold hover:text-zinc-700 tracking-wide"
              >
                Continue with email
              </.link>
            </div>
          </button>
          <p class="text-xs text-gray-500 px-16 md:px-6 max-w-sm leading-loose text-center">
            By creating an account, you agree to EasyBills Company's <br class="md:hidden" />
            <a href="#" class="font-bold">Terms of Use</a>
            and <a href="#" class="font-bold">Privacy Policy</a>.
          </p>
          <p class="mx-w-sm mx-auto">
            Don't have an account?
            <.link
              href={~p"/register"}
              class="leading-6 text-purple-500 font-semibold hover:text-zinc-700"
            >
              Sign up
            </.link>
          </p>
        </div>
      </div>
    </RegularTemplate.regular>
    """
  end
end
