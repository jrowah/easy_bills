defmodule EasyBillsWeb.Landing.LandingLive do
  @moduledoc """
  Landing page
  """
  use EasyBillsWeb, :live_view

  alias EasyBillsWeb.CommonComponents.Icons
  alias EasyBillsWeb.OnboardingLive.Shared.RegularTemplate

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
