defmodule EasyBills.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :from, :map
      add :client, :map
      add :due_at, :date
      add :amount, :string
      add :status, :string
      add :description, :string
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create unique_index(:invoices, [:user_id])
  end
end
