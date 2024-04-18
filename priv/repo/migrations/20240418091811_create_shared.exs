defmodule Ploty.Repo.Migrations.CreateShared do
  use Ecto.Migration

  def change do
    create table(:shared) do
      add :user_id, references(:users, on_delete: :delete_all), null: false, primary_key: true
      add :plot_id, references(:plots, on_delete: :delete_all), null: false, primary_key: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:shared, [:user_id, :plot_id], name: :shared_uniqueness)
  end
end
