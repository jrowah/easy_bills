defmodule EasyBillsWeb.Access.RegistrationLive do
  @moduledoc false

  use EasyBillsWeb, :live_view

  alias EasyBills.Accounts
  alias EasyBills.Accounts.User
  alias EasyBillsWeb.Access.SharedComponents
  alias EasyBillsWeb.OnboardingLive.UserRegistration

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)
      |> assign(:template, :new)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  @impl Phoenix.LiveView
  def render(%{template: :new} = assigns) do
    ~H"""
    <.live_component
      module={UserRegistration.New}
      id="registration_form"
      form={@form}
      check_errors={@check_errors}
      trigger_submit={@trigger_submit}
    />
    """
  end

  def render(%{template: :success} = assigns) do
    ~H"""
    <SharedComponents.registration_success_page form={@form} title="Confirm your Email Address" />
    """
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/access/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)

        {:noreply,
         socket
         |> assign_form(changeset)
         |> assign(:template, :success)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("resend_confirmation", %{"user_email" => user_email}, socket) do
    case Accounts.get_user_by_email(user_email) do
      user ->
        Accounts.deliver_user_confirmation_instructions(
          user,
          &url(~p"/access/confirm/#{&1}")
        )

        {:noreply,
         socket
         |> put_flash(:info, "Confirmation instructions to email resent successfully.")
         |> redirect(to: ~p"/auth/login")}
    end
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
