defmodule PlotyWeb.PlotLive.ShareComponent do
  use PlotyWeb, :live_component

  alias Ploty.Accounts
  alias Ploty.Plots
  alias Ploty.Plots.Shared

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Share the plot with a user</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="shared-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:user_id]}
          type="select"
          label="User"
          options={@users}
          prompt="Select User"
        />
        <.input field={@form[:plot_id]} type="hidden" value={@plot.id} />

        <:actions>
          <.button :if={@form.source.valid?} phx-disable-with="Saving...">Share Plot</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    users =
      assigns.plot
      |> Accounts.users_to_share_with()
      |> Enum.reduce([], &Keyword.merge(&2, "#{&1.email}": &1.id))

    changeset = Plots.change_shared(%Shared{}, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(users: users)
     |> assign(shared: %Shared{})
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"shared" => shared_params}, socket) do
    changeset =
      socket.assigns.shared
      |> Plots.change_shared(shared_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"shared" => shared_params}, socket) do
    case Plots.create_shared(shared_params) do
      {:ok, _shared} ->
        {:noreply,
         socket
         |> put_flash(:info, "Plot shared successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
