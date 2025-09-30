defmodule EasyBillsWeb.Dashboard.Hooks.Session do
  @moduledoc """
  This module provides session management hooks for the EasyBillsWeb dashboard.
  It includes functions to mount the current user and ensure that the user completes onboarding.
  """
  use EasyBillsWeb, :live_view

  alias EasyBills.Accounts

  def on_mount(_default, params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, _socket} = socket |> setup(params, session) |> complete()
    else
      socket =
        socket
        |> put_flash(:error, "You must log in to access this page.")
        |> redirect(to: ~p"/access/login")

      {:halt, socket}
    end
  end

  defp setup(socket, session, _params) do
    socket
    |> assign(:scope, :dashboard)
    |> assign(:current_path, session["current_path"] || "/dashboard")
  end

  defp complete(socket) do
    user = Accounts.get_user!(socket.assigns.current_user.id)

    cond do
      is_nil(user.avatar_url) ->
        {:cont,
         socket
         |> assign(:pending_avatar_upload, true)
         |> assign(:pending_business_address, false)}

      is_nil(user.business_address) ->
        {:cont,
         socket
         |> assign(:pending_business_address, true)
         |> assign(:pending_avatar_upload, false)}

      true ->
        {:cont,
         socket
         |> assign(:pending_avatar_upload, false)
         |> assign(:pending_business_address, false)}
    end
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if user_token = session["user_token"] do
        Accounts.get_user_by_session_token(user_token)
      end
    end)
  end
end
