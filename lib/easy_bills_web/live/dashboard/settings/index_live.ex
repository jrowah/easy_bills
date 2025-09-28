defmodule EasyBillsWeb.Dashboard.Settings.IndexLive do
  @doc """
  Settings LiveView
  """
  use EasyBillsWeb, :live_view

  alias EasyBills.Accounts
  alias EasyBillsWeb.CommonComponents.NavComponent
  alias EasyBillsWeb.SettingsComponents.EditBioComponent
  alias EasyBillsWeb.SettingsComponents.EditPasswordComponent
  alias EasyBillsWeb.SettingsComponents.EmailNotificationsComponent

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/dashboard/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)

    password_changeset =
      Accounts.change_user_password(user)

    address_changeset =
      Accounts.change_user_address(user)

    # notifications_changeset =
    # Accounts.change_user_notifications(user) |> IO.inspect(label: "notifications_changeset")

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:address_form, to_form(address_changeset))
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:email_notifications_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/dashboard/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("delete_account", _params, socket) do
    user = socket.assigns.current_user

    case Accounts.delete_user(user) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Your account has been deleted.")
         |> push_navigate(to: ~p"/")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp apply_action(socket, :edit_bio, _params) do
    socket
    |> assign(:page_title, "Edit Profile Information")
  end

  defp apply_action(socket, :edit_password, _params) do
    socket
    |> assign(:page_title, "Change Password")
  end

  defp apply_action(socket, :edit_email_notifications, _params) do
    socket
    |> assign(:page_title, "Edit Notification Preferences")
  end
end
