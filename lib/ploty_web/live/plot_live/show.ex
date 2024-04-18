defmodule PlotyWeb.PlotLive.Show do
  use PlotyWeb, :live_view

  alias Ploty.Plots

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:plot, Plots.get_plot!(id))}
  end

  @impl true
  def handle_event("update-plot", _, socket) do
    plot = socket.assigns.plot

    {:noreply,
      socket
      |> push_event("update-histogram-#{plot.id}", %{
        trace: %{x: [0, 10, 10, 3, 6, 8, 9, 2, 3, 8, 7, 5, 4, 5, 8, 9, 6, 8, 9, 2, 2, 6, 8]}
      })}
  end

  defp page_title(:show), do: "Show Plot"
  defp page_title(:edit), do: "Edit Plot"
end
