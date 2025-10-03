defmodule EasyBills.Repo.Migrations.AddItemsColumnForEmbeddedItemsSchema do
  use Ecto.Migration

  def up do
    alter table(:invoices) do
      add :items, :map
    end
  end

  def down do
    alter table(:invoices) do
      remove :items
    end
  end
end
