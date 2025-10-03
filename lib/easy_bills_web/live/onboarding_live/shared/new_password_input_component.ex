defmodule EasyBillsWeb.OnboardingLive.Shared.NewPasswordInputComponent do
  @moduledoc false

  use EasyBillsWeb, :html

  alias EasyBillsWeb.OnboardingLive.Shared.InputComponents
  alias EasyBillsWeb.Access.SharedComponents

  @type assigns :: map()
  @type output :: Phoenix.LiveView.Rendered.t()

  @spec new_password_input(assigns()) :: output()
  def new_password_input(assigns) do
    assigns = assign_password_input_errors(assigns)

    ~H"""
    <InputComponents.input_field
      autocomplete="new-password"
      custom_errors={true}
      field={@form[:password]}
      input_class="relative"
      label={@label}
      label_type="icon"
      placeholder="Enter Your Password"
      type="password"
      required
    >
      <:error_messages>
        <p class="font-[300] font-sohne-leicht text-xs my-2">Password must contain:</p>
        <.password_error_list password_input_errors={@password_input_errors} />
      </:error_messages>
    </InputComponents.input_field>
    """
  end

  defp assign_password_input_errors(assigns) do
    password_input_errors =
      assigns.form.errors
      |> Stream.filter(fn {key, _message} -> key == :password end)
      |> Enum.reduce([], fn {_key, {message, _validation}}, acc ->
        case message do
          "must have at least one upper-case character" -> [:uppercase | acc]
          "must be at least 8+ characters" -> [:length | acc]
          "must have at least one special character (*#$%&!-@)" -> [:special_character | acc]
          "must have at least 1 digit" -> [:digit | acc]
          "can't be blank" -> [:blank | acc]
        end
      end)

    assign(assigns, password_input_errors: password_input_errors)
  end

  defp password_condition_color(password_condition_errors, condition) do
    if Enum.empty?(password_condition_errors) do
      "phx-no-feedback:text-gray-500 text-green-500"
    else
      color_errors(password_condition_errors, condition)
    end
  end

  defp color_errors(password_condition_errors, condition) do
    if Enum.member?(password_condition_errors, condition) ||
         Enum.member?(password_condition_errors, :blank),
       do: "phx-no-feedback:text-gray-500 text-red-500",
       else: "phx-no-feedback:text-gray-500 text-green-500"
  end

  defp password_condition_icon(assigns) do
    ~H"""
    <%= if Enum.empty?(@errors) do %>
      <SharedComponents.password_criteria_icon
        stroke_color="#D9D9D9"
        class="hidden phx-no-feedback:block"
      />
      <SharedComponents.password_criteria_icon stroke_color="#4CAF50" class="phx-no-feedback:hidden" />
    <% else %>
      <.set_error_icon errors={@errors} condition={@condition} />
    <% end %>
    """
  end

  defp set_error_icon(assigns) do
    ~H"""
    <%= if (@condition in @errors || :blank in @errors) do %>
      <SharedComponents.password_criteria_not_met_icon class="phx-no-feedback:hidden" />
      <SharedComponents.password_criteria_icon
        stroke_color="#D9D9D9"
        class="hidden phx-no-feedback:block"
      />
    <% else %>
      <SharedComponents.password_criteria_icon
        stroke_color="#D9D9D9"
        class="hidden phx-no-feedback:block"
      />
      <SharedComponents.password_criteria_icon stroke_color="#4CAF50" class="phx-no-feedback:hidden" />
    <% end %>
    """
  end

  defp password_error_list(assigns) do
    ~H"""
    <ul class="grid grid-cols-2 mt-3">
      <div class="grid gap-y-2">
        <.password_condition
          description="8+ characters"
          password_input_errors={@password_input_errors}
          condition={:length}
        />

        <.password_condition
          description="upper - case"
          password_input_errors={@password_input_errors}
          condition={:uppercase}
        />
      </div>

      <div class="grid gap-y-2">
        <.password_condition
          description="number"
          password_input_errors={@password_input_errors}
          condition={:digit}
        />

        <.password_condition
          description="special character (*#$%&!-@)"
          password_input_errors={@password_input_errors}
          condition={:special_character}
        />
      </div>
    </ul>
    """
  end

  attr :description, :string, required: true
  attr :password_input_errors, :list
  attr :condition, :atom, required: true

  defp password_condition(assigns) do
    ~H"""
    <li>
      <p
        data-error={if(@condition in @password_input_errors, do: "#{to_string(@condition)}")}
        class={[
          "flex text-xs font-light gap-2 items-center",
          password_condition_color(@password_input_errors, @condition)
        ]}
      >
        <span>
          <.password_condition_icon errors={@password_input_errors} condition={@condition} />
        </span>
        <span><%= @description %></span>
      </p>
    </li>
    """
  end
end
