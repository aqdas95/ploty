defmodule PlotyWeb.SharedLive.Index do
  use PlotyWeb, :live_view

  alias Ploty.Plots

  @impl true
  def mount(_params, _session, socket) do
    Plots.list_shared(socket.assigns.current_user.id)
    {:ok, stream(socket, :shared, Plots.list_shared(socket.assigns.current_user.id))}
  end
end
