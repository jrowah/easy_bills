defmodule EasyBills.Repo.Migrations.AddStatusColumnToInvoicesTable do
  use Ecto.Migration

  def up do
    alter table(:invoices) do
      add :status, :string, default: "draft"
    end
  end

  def down do
    alter table(:invoices) do
      remove :status
    end
  end
end
