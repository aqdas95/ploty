defmodule Ploty.PlotsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ploty.Plots` context.
  """

  alias Ploty.AccountsFixtures

  @doc """
  Generate a plot.
  """
  def plot_fixture(attrs \\ %{}) do
    {:ok, plot} =
      attrs
      |> Enum.into(%{
        dataset: "some dataset",
        expression: "some expression",
        name: "some name",
        creator_id: AccountsFixtures.user_fixture().id
      })
      |> Ploty.Plots.create_plot()

    plot
  end
end
