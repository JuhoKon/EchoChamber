defmodule EchochamberWeb.RadioLive.FormComponent do
  use EchochamberWeb, :live_component

  alias Echochamber.Radios

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="radio-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:url]} type="text" label="Url" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:genre]} type="text" label="Genre" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Radio</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{radio: radio} = assigns, socket) do
    changeset = Radios.change_radio(radio)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"radio" => radio_params}, socket) do
    changeset =
      socket.assigns.radio
      |> Radios.change_radio(radio_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"radio" => radio_params}, socket) do
    save_radio(socket, socket.assigns.action, radio_params)
  end

  defp save_radio(socket, :edit, radio_params) do
    case Radios.update_radio(socket.assigns.radio, radio_params) do
      {:ok, radio} ->
        notify_parent({:saved, radio})

        {:noreply,
         socket
         |> put_flash(:info, "Radio updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_radio(socket, :new, radio_params) do
    case Radios.create_radio(radio_params) do
      {:ok, radio} ->
        notify_parent({:saved, radio})

        {:noreply,
         socket
         |> put_flash(:info, "Radio created successfully")
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
