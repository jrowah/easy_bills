defmodule EasyBillsWeb.Dashboard.AddAvatar do
  @moduledoc false

  use EasyBillsWeb, :live_component

  alias EasyBills.Accounts.User
  alias EasyBillsWeb.CommonComponents.Icons
  alias EasyBillsWeb.OnboardingLive.Shared.RegularTemplate

  import Phoenix.HTML.Form

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def update(assigns, socket) do
    socket = assign(socket, assigns)
    user = socket.assigns.current_user

    changeset = User.registration_changeset(user, %{})

    {:ok,
     socket
     |> assign(:changeset, changeset)
     |> assign(:uploaded_files, [])
     |> assign(:avatar_selected?, false)
     |> allow_upload(:avatar_url,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1
     )}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <RegularTemplate.regular>
        <div class="mx-auto mt-16" id="avatar-image-container" phx-hook="UserAvatar">
          <div class="flex mb-4 hidden lg:block">
            <Icons.logo_icon />
          </div>
          <h3 class="font-bold text-2xl">
            Welcome! Let's create your profile.
          </h3>
          <p class="text-gray-400">Just a few more steps...</p>

          <div class="mt-16">
            <h4 class="font-bold mt-6">Add an avatar</h4>
            <div class="w-32 h-32 rounded-full border-2 border-dashed border-gray-400">
              <%= for entry <- @uploads.avatar_url.entries do %>
                <figure>
                  <.live_img_preview entry={entry} class="rounded-full w-32 h-32" />
                </figure>
              <% end %>
            </div>
            <.form
              for={@changeset}
              id="upload-form"
              phx-change="validate"
              phx-submit="save"
              phx-target={@myself}
            >
              <div class="relative flex items-center">
                <.live_file_input
                  upload={@uploads.avatar_url}
                  id="live-file-input"
                  class="invisible live-file-input"
                  phx-change="enable-button"
                />
                <span
                  id="avatar-upload-button"
                  class="absolute left-1/2 transform -translate-y-[180%] bg-purple-600 text-white py-2 px-6 rounded-full cursor-pointer font-bold"
                >
                  Choose Image
                </span>
              </div>

              <button
                type="submit"
                class={"mt-36 text-white py-2 px-6 rounded-full ml-[70%] font-bold" <> if(@avatar_selected?, do: " bg-gray-500", else: " bg-gray-300")}
                phx-disable-with="Submitting..."
                disabled={!@avatar_selected?}
              >
                Continue
              </button>
            </.form>
          </div>
        </div>

        <section phx-drop-target={@uploads.avatar_url.ref}>
          <%= for entry <- @uploads.avatar_url.entries do %>
            <%= for err <- upload_errors(@uploads.avatar_url, entry) do %>
              <p class="alert alert-danger"><%= humanize(err) %></p>
            <% end %>
          <% end %>
        </section>
      </RegularTemplate.regular>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("enable-button", _params, socket) do
    {:noreply, socket |> assign(:avatar_selected?, true)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :avatar_url, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:easy_bills), "static", "uploads", Path.basename(path)])
        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)

    user = socket.assigns.current_user
    new_avatar_url = Enum.at(uploaded_files, 0)
    user_changeset = Ecto.Changeset.change(user, %{avatar_url: new_avatar_url})

    case EasyBills.Accounts.add_user_avatar(user_changeset) do
      {:ok, _user} ->
        send(self(), {:added_avatar, %{}})

        {:noreply,
         socket
         |> update(:uploaded_files, &(&1 ++ uploaded_files))}

      {:error, _changeset} ->
        {:noreply, socket}
    end

    {:noreply,
     socket
     |> update(:uploaded_files, &(&1 ++ uploaded_files))}
  end
end
