defmodule EasyBillsWeb.CommonComponents.NavComponent do
  @moduledoc """
  Navigation component
  """

  alias EasyBillsWeb.CommonComponents.Icons

  use EasyBillsWeb, :html

  @type assigns :: map
  @type output :: Phoenix.LiveView.Rendered.t()

  @spec navbar(assigns()) :: output()
  def navbar(assigns) do
    ~H"""
    <div>
      <nav class="bg-black flex flex-col fixed w-58 h-full justify-between z-40 rounded-r-3xl">
        <Icons.logo_icon_white />
        <div class="space-x-auto text-center">
          <div
            id="theme-toggle"
            phx-click="toggle_dark_mode"
            class="border-b-2 mb-4 pb-2 text-white"
            phx-hook="DarkModeToggle"
          >
            <span id="theme-toggle-light-icon" class="cursor-pointer">
              <.icon name="hero-moon" />
            </span>
            <span id="theme-toggle-dark-icon" class="hidden cursor-pointer">
              <.icon name="hero-sun" />
            </span>
          </div>
          <img
            id="profile-toggler"
            src={@current_user.avatar_url}
            alt={"#{@current_user.username}'s" <> " Avatar"}
            class="rounded-full h-20 w-20 mx-auto mb-6 cursor-pointer"
            phx-click={show_modal("profile-modal")}
          />
        </div>
      </nav>
      <.profile_modal id="profile-modal">
        <div class="text-center rounded-lg ml-[25%]">
          <img
            src={@current_user.avatar_url}
            alt={"#{@current_user.username}'s" <> " Avatar"}
            class="rounded-full h-20 w-20 mx-auto mb-6 cursor-pointer"
            phx-click={show_modal("profile-modal")}
          />
          <h4 class="mb-2 text-lg font-bold text-zinc-800">
            <%= @current_user.username <> " " <> @current_user.name %>
          </h4>
          <div class="flex flex-col space-y-4 ml-24">
            <.link
              navigate={~p"/dashboard"}
              class="text-[0.8125rem] leading-6 text-gray-500 font-semibold hover:text-zinc-700"
            >
              <div class="flex items-center space-x-3">
                <Icons.dashboard_icon /> <span>Dashboard</span>
              </div>
            </.link>
            <.link
              navigate={~p"/dashboard/invoices"}
              class="text-[0.8125rem] leading-6 text-gray-500 font-semibold hover:text-zinc-700"
            >
              <div class="flex items-center space-x-3">
                <.icon name="hero-document-text-solid" class="text-[#7C5DFA]" /> <span>Invoices</span>
              </div>
            </.link>
            <.link
              navigate={~p"/dashboard/expenses"}
              class="text-[0.8125rem] leading-6 text-gray-500 font-semibold hover:text-zinc-700"
            >
              <div class="flex items-center space-x-3">
                <.icon name="hero-banknotes-solid" class="text-[#7C5DFA]" /> <span>Expenses</span>
              </div>
            </.link>
            <.link
              navigate={~p"/dashboard/settings"}
              class="text-[0.8125rem] leading-6 text-gray-500 font-semibold hover:text-zinc-700"
            >
              <div class="flex items-center space-x-3">
                <Icons.settings_icon /> <span>Settings</span>
              </div>
            </.link>
            <.link
              href={~p"/auth/logout"}
              method="delete"
              class="text-[0.8125rem] leading-6 text-gray-500 font-semibold hover:text-zinc-700"
            >
              <div class="flex items-center space-x-3">
                <Icons.sign_out_icon /> <span>Log out</span>
              </div>
            </.link>
          </div>
        </div>
      </.profile_modal>
    </div>
    """
  end
end
