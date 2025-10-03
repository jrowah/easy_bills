defmodule EasyBillsWeb.OnboardingLive.Shared.InputComponents do
  @moduledoc false

  use Phoenix.Component

  alias EasyBillsWeb.CoreComponents

  @type assigns :: map()
  @type output :: Phoenix.LiveView.Rendered.t()

  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :error_class, :string, default: ""
  attr :class, :string, default: nil
  attr :input_class, :string, default: nil

  attr :label_type, :string, required: true, values: ~w(text icon none)
  attr :custom_errors, :boolean, default: false

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot :error_messages
  slot :input_icon
  slot :inner_block

  @spec input_field(assigns()) :: output()
  def input_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &CoreComponents.translate_error(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input_field()
  end

  def input_field(%{label_type: "text"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={@class}>
      <div class={[
        "appearance-none",
        @errors == [] && "border-opacity-0",
        @errors == [] && "border-opacity-100",
        @input_class
      ]}>
        <.label for={@id} class="phx-no-feedback:text-gray-400 ml-2" errors={@errors}>
          <%= @label %>
        </.label>

        <input
          type={@type}
          name={@name}
          id={@id}
          value={@value}
          class={[
            "w-full h-full font-sohne-leicht text-sm border-0 focus:ring-0 phx-no-feedback:text-gray-400 phx-no-feedback:placeholder:text-gray-400",
            @error == [] && "placeholder:text-gray-400",
            @error != [] && "placeholder:text-red-500 text-error"
          ]}
          {@rest}
        />
      </div>
      <%= if @custom_errors do %>
        <%= render_slot(@error_messages) %>
      <% else %>
        <.error
          :for={msg <- @errors}
          class="font-bold text-red-500 text-sm phx-no-feedback:hidden mt-1"
        >
          <%= msg %>
        </.error>
      <% end %>
    </div>
    """
  end

  def input_field(%{label_type: "icon"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={@class}>
      <.label for={@id} class="phx-no-feedback:text-zinc-700 dark:text-white" errors={@errors}>
        <%= @label %>
      </.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "input-field mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 border-zinc-300 focus:border-zinc-400",
          @errors == [] && "placeholder:text-gray-500",
          @errors != [] && "placeholder:text-red-500 text-error"
        ]}
        {@rest}
      />
      <%= if @custom_errors do %>
        <%= render_slot(@error_messages) %>
      <% else %>
        <.error
          :for={msg <- @errors}
          class={"font-bold text-red-500 text-sm phx-no-feedback:hidden mt-1"<> @error_class}
        >
          <%= msg %>
        </.error>
      <% end %>
    </div>
    """
  end

  def input_field(%{label_type: "none"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={["grid gap-y-2 mb-4", @class]}>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "w-full h-full font-sohne-leicht text-sm border-0 focus:ring-0 phx-no-feedback:text-gray-400 phx-no-feedback:placeholder:text-gray-400",
          @errors == [] && "placeholder:text-gray-400",
          @errors != [] && "placeholder:text-red-500 text-error"
        ]}
        {@rest}
      />
      <.error
        :for={msg <- @errors}
        class={"font-bold text-red-500 text-sm phx-no-feedback:hidden mt-1"<> @error_class}
      >
        <%= msg %>
      </.error>
    </div>
    """
  end

  @doc """
  Generates a generic error message
  """
  @spec error(assigns()) :: output()
  def error(assigns) do
    ~H"""
    <p class={@class}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Generates a generic label
  """

  attr :class, :string, default: nil
  attr :errors, :list, default: []
  attr :for, :string, default: nil

  slot :inner_block, required: true

  @spec label(assigns()) :: output()
  def label(assigns) do
    ~H"""
    <label
      for={@for}
      class={[
        "font-sohne-leitch text-sm",
        @errors == [] && "text-gray-400",
        @errors != [] && "text-red-500",
        @class
      ]}
    >
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Renders a submit button
  """

  @spec submit_button(assigns()) :: output()
  def submit_button(assigns) do
    ~H"""
    <button type="submit" class={["w-full font-sohne-kraftig rounded-lg", @class]} , id={@id}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
