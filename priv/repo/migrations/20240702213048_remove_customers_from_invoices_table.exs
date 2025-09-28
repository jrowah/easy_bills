defmodule EasyBills.Repo.Migrations.RemoveCustomersFromInvoicesTable do
  use Ecto.Migration

  def up do
    alter table(:invoices) do
      remove :client
      remove :from
      remove :status
      remove :amount

      add :client_city, :string
      add :client_country, :string
      add :client_email, :string
      add :client_name, :string
      add :client_postal_code, :string
      add :client_street_address, :string
      add :terms, :string
    end
  end

  def down do
    alter table(:invoices) do
      add :client, :map
      add :from, :map
      add :status, :string
    end
  end
end
