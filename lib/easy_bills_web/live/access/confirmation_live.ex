defmodule EasyBillsWeb.Access.ConfirmationLive do
  use EasyBillsWeb, :live_view

  alias EasyBills.Accounts
  alias EasyBillsWeb.CommonComponents.{ErrorPages, Icons}

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div>
      <%= if assigns[:user] do %>
        <div class="mx-auto max-w-[600px] mt-20">
          <div class="flex items-center">
            <Icons.logo_icon_white />
            <span class="ml-4 text-purple-600 font-bold text-3xl">Invoices</span>
          </div>
          <.header class="">Hi, <%= @user.username %></.header>
          <p>Welcome to EasyBills,</p>
          <hr class="my-2" />
          <p class="mb-6">
            Please take a second to confirm <%= @user.email %> as your email address:
          </p>
          <p>
            Once you do, you will be able to opt-in to notifications of activity and access other features that require a valid email address.
          </p>
          <.simple_form for={@form} id="confirmation_form" phx-submit="confirm_account">
            <.input field={@form[:token]} type="hidden" />
            <:actions>
              <.button phx-disable-with="Confirming..." class="w-1/2 mx-auto">
                Confirm email
              </.button>
            </:actions>
          </.simple_form>
          <p class="mt-6">High fives, <br /> Team EasyBills</p>

          <p class="mt-4 text-gray-500 text-sm">
            If the button above does not work, try copying and pasting the URL into your browser.
          </p>
        </div>
      <% else %>
        <ErrorPages.invalid_token_error_page />
      <% end %>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    {:ok, decoded_token} = Base.url_decode64(token, padding: false)
    hashed_token = :crypto.hash(:sha256, decoded_token)

    user = Accounts.get_user_by_confirmation_token(hashed_token)
    form = to_form(%{"token" => token}, as: "user")

    {:ok,
     socket
     |> assign(form: form)
     |> assign(user: user)
     |> assign(temporary_assigns: [form: nil])}
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def handle_event("confirm_account", %{"user" => %{"token" => token}}, socket) do
    case Accounts.confirm_user(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "User confirmed successfully.")
         |> redirect(to: ~p"/access/login")}

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "User confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/")}
        end
    end
  end
end
