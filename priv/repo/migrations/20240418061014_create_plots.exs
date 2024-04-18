defmodule Ploty.Repo.Migrations.CreatePlots do
  use Ecto.Migration

  def change do
    create table(:plots) do
      add :name, :string
      add :dataset, :string
      add :expression, :string
      add :expression_data, {:array, :string}
      add :creator_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
