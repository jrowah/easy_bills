defmodule EasyBills.Billing.Invoice do
  @moduledoc """
  The Invoice schema represents an invoice issued by a user to a client.
  It includes details such as due date, client information, line items, and terms.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias EasyBills.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "invoices" do
    field :description, :string
    field :due_at, :date
    field :client_name, :string
    field :client_email, :string
    field :client_street_address, :string
    field :client_city, :string
    field :client_postal_code, :string
    field :client_country, :string
    field :terms, :string
    field :status, Ecto.Enum, values: [:draft, :paid, :pending, :cancelled], default: :draft

    belongs_to :user, User

    embeds_many :items, Item do
      field :item_name, :string
      field :quantity, :integer
      field :unit_price, :float
    end

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [
      :due_at,
      :description,
      :client_name,
      :client_email,
      :client_street_address,
      :client_city,
      :client_postal_code,
      :client_country,
      :terms,
      :status
    ])
    |> validate_required([
      :due_at,
      :description,
      :client_name,
      :client_email,
      :client_street_address,
      :client_city,
      :client_postal_code,
      :client_country,
      :terms
    ])
    |> cast_embed(:items, with: &items_changeset/2)
  end

  defp items_changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:item_name, :quantity, :unit_price])
    |> validate_required([:item_name, :quantity, :unit_price])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:unit_price, greater_than: 0.0)
  end

  @doc """
  Returns all possible status values as atoms.
  """
  def status_options, do: [:draft, :paid, :pending, :cancelled]

  @doc """
  Converts status atom to human readable string.
  """
  def status_display(status) do
    case status do
      :draft -> "Draft"
      :pending -> "Pending"
      :paid -> "Paid"
      :cancelled -> "Cancelled"
    end
  end

  @doc """
  Returns true if the invoice can be edited.
  """
  def editable?(%__MODULE__{status: status}) do
    status in [:draft]
  end

  @doc """
  Returns true if the invoice can be sent.
  """
  def sendable?(%__MODULE__{status: status}) do
    status in [:draft]
  end
end
