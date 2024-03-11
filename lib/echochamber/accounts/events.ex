defmodule Echochamber.Accounts.Events do
  defmodule Pause do
    defstruct radio_url: nil, radio_title: nil
  end

  defmodule Play_Pause do
    defstruct radio_url: nil, radio_title: nil
  end

  defmodule Play_Song do
    defstruct radio_url: nil, radio_title: nil
  end

  defmodule Stop_Song do
    defstruct radio_url: nil, radio_title: nil
  end
end
