defmodule Ploty.Plots do
  @moduledoc """
  The Plots context.
  """

  import Ecto.Query, warn: false
  alias Ploty.Repo

  alias Ploty.Plots.Plot
  alias Ploty.Plots.Shared

  @doc """
  Returns the list of plots based on a creator.

  ## Examples

      iex> list_plots(5)
      [%Plot{creator_id: 5}, ...]

  """
  def list_plots(creator_id) do
    from(p in Plot, where: p.creator_id == ^creator_id)
    |> Repo.all()
  end


  @doc """
  Gets a single plot.

  Raises `Ecto.NoResultsError` if the Plot does not exist.

  ## Examples

      iex> get_plot!(123)
      %Plot{}

      iex> get_plot!(456)
      ** (Ecto.NoResultsError)

  """
  def get_plot!(id), do: Repo.get!(Plot, id)

  @doc """
  Creates a plot.

  ## Examples

      iex> create_plot(%{field: value})
      {:ok, %Plot{}}

      iex> create_plot(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_plot(attrs \\ %{}) do
    %Plot{}
    |> Plot.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a plot.

  ## Examples

      iex> update_plot(plot, %{field: new_value})
      {:ok, %Plot{}}

      iex> update_plot(plot, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_plot(%Plot{} = plot, attrs) do
    plot
    |> Plot.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a plot.

  ## Examples

      iex> delete_plot(plot)
      {:ok, %Plot{}}

      iex> delete_plot(plot)
      {:error, %Ecto.Changeset{}}

  """
  def delete_plot(%Plot{} = plot) do
    Repo.delete(plot)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking plot changes.

  ## Examples

      iex> change_plot(plot)
      %Ecto.Changeset{data: %Plot{}}

  """
  def change_plot(%Plot{} = plot, attrs \\ %{}) do
    Plot.changeset(plot, attrs)
  end

  @doc """
  Returns the list of shared plots for a user_id.

  ## Examples

      iex> list_plots(5)
      [%Plot{creator_id: 5}, ...]

  """
  def list_shared(user_id) do
    from(s in Shared, where: s.user_id == ^user_id)
    |> Repo.all()
    |> Repo.preload(:plot)
  end

  @doc """
  Creates a shared entry for given plot

  ## Examples

      iex> create_shared(goo_value)
      {:ok, %Shared{}}

      iex> create_shared(plot, bad_value)
      {:error, %Ecto.Changeset{}}


  """
  def create_shared(params) do
    %Shared{}
    |> Shared.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking plot changes.

  ## Examples

      iex> change_shared(shared)
      %Ecto.Changeset{data: %Shared{}}

  """
  def change_shared(%Shared{} = shared, attrs \\ %{}) do
    Shared.changeset(shared, attrs)
  end
end
