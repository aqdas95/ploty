defmodule PlotyWeb.PlotLive.FormComponent do
  use PlotyWeb, :live_component

  alias Phoenix.LiveView.AsyncResult
  alias Ploty.Plots

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage plot records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="plot-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <span class="text-xs">This is an arbitrary name for the chart and can be any string</span>

        <.input field={@form[:dataset]} phx-debounce="1000" type="text" label="Dataset" />
        <span class="text-xs">
          Dataset should be a valid csv file name from
          &nbsp;<a href="https://github.com/plotly/datasets/tree/master" target="blank">here</a>.
          <br />
          <b>Note: Do not add the file extension.</b>
        </span>

        <.input field={@form[:expression]} phx-debounce="1000" type="text" label="Expression" />
        <span class="text-xs">Expression should be a valid column name from the selected csv</span>

        <div>
          <.async_result :let={plots} assign={@plots}>
            <:loading>Waiting for Preview</:loading>
            <:failed :let={reason}><%= reason %></:failed>

            <.histogram :if={plots} id={0} series={plots} />
          </.async_result>
        </div>

        <:actions>
          <.button :if={@plots.ok?} phx-disable-with="Saving...">Save Plot</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{plot: plot} = assigns, socket) do
    changeset = Plots.change_plot(plot)

    plots =
      if assigns.action == :edit do
        AsyncResult.ok(plot.expression_data)
      else
        AsyncResult.loading()
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:plots, plots)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"plot" => plot_params, "_target" => _target}, socket) do
    changeset =
      socket.assigns.plot
      |> Plots.change_plot(plot_params)
      |> Map.put(:action, :validate)

    plot = Map.merge(socket.assigns.plot, changeset.changes)

    {:noreply,
     socket
     |> assign_form(changeset)
     |> assign(:plots, AsyncResult.loading())
     |> start_async(:fetch_data, fn -> Plots.fetch_plot_data(plot) end)}
  end

  def handle_event("save", %{"plot" => _plot_params}, socket) do
    save_plot(socket, socket.assigns.action, socket.assigns.form.params)
  end

  @impl true
  def handle_async(:fetch_data, {:ok, {:ok, result}}, socket) do
    %{plots: plots, form: form} = socket.assigns

    changeset =
      Plots.change_plot(socket.assigns.plot, Map.put(form.params, "expression_data", result))

    {:noreply,
     socket
     |> assign(:plots, AsyncResult.ok(plots, result))
     |> assign_form(changeset)}
  end

  def handle_async(:fetch_data, {:ok, {:error, reason}}, socket) do
    %{plots: plots, form: form} = socket.assigns

    invalid_attr = if reason =~ "expression", do: :expression, else: :dataset
    changeset = Ecto.Changeset.add_error(form.source, invalid_attr, reason)

    {:noreply,
     socket
     |> assign(:plots, AsyncResult.failed(plots, reason))
     |> assign_form(changeset)}
  end

  defp save_plot(socket, :edit, plot_params) do
    case Plots.update_plot(socket.assigns.plot, plot_params) do
      {:ok, plot} ->
        notify_parent({:saved, plot})

        {:noreply,
         socket
         |> put_flash(:info, "Plot updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_plot(socket, :new, plot_params) do
    case plot_params
         |> Map.put("creator_id", socket.assigns.current_user.id)
         |> Plots.create_plot() do
      {:ok, plot} ->
        notify_parent({:saved, plot})

        {:noreply,
         socket
         |> put_flash(:info, "Plot created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
