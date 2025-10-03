defmodule EasyBillsWeb.Access.ForgotPasswordLive do
  use EasyBillsWeb, :live_view

  alias EasyBills.Accounts
  alias EasyBillsWeb.CommonComponents.Icons
  alias EasyBillsWeb.CoreComponents
  alias EasyBillsWeb.OnboardingLive.Shared.RegularTemplate

  def render(assigns) do
    ~H"""
    <RegularTemplate.regular>
      <div class="my-auto mx-auto space-y-16 max-w-md">
        <.link
          href={~p"/login"}
          id="back-icon"
          class="flex text-purple-600 dark:text-white absolute ml-[-8%] mt-6 lg:mt-[-4%]"
        >
          <CoreComponents.back_icon /> <span class="mt-[-2px] ml-1">Back</span>
        </.link>
        <div class="flex mb-4 hidden lg:block">
          <Icons.logo_icon />
        </div>
        <.header class="text-center">
          Forgot password?
          <:subtitle>
            <b>Enter the email</b>
            that you used to create your account and we will send you a
            <b>link to reset your password</b>
          </:subtitle>
        </.header>

        <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
          <.input field={@form[:email]} label="Email" type="email" placeholder="Email" required />
          <:actions>
            <.button phx-disable-with="Sending..." class="w-full">
              Send reset link
            </.button>
          </:actions>
        </.simple_form>
        <p class="text-center text-sm mt-4">
          <.link href={~p"/access/register"}>Register</.link>
          | <.link href={~p"/access/login"}>Log in</.link>
        </p>
      </div>
    </RegularTemplate.regular>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/access/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
