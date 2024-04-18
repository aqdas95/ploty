defmodule Ploty.Plots.Shared do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shared" do
    belongs_to :user, Ploty.Accounts.User
    belongs_to :plot, Ploty.Plots.Plot

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shared, attrs) do
    shared
    |> cast(attrs, [:user_id, :plot_id])
    |> validate_required([:user_id, :plot_id])
    |> unique_constraint([:user_id, :plot_id],
      name: :shared_uniqueness,
      message: "Plot already shared with selected user"
    )
  end
end
