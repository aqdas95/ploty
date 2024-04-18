defmodule Ploty.Plots.Plot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plots" do
    field :name, :string
    field :dataset, :string
    field :expression, :string
    field :expression_data, {:array, :string}
    belongs_to :creator, Ploty.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(plot, attrs) do
    plot
    |> cast(attrs, [:name, :dataset, :expression, :expression_data, :creator_id])
    |> validate_required([:name, :dataset, :expression, :expression_data, :creator_id])
  end
end
