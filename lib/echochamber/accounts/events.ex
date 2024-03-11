defmodule Echochamber.Accounts.Events do
  defmodule Pause do
    defstruct radio_url: nil, radio_title: nil, track_title: nil, playing?: false
  end

  defmodule Play_Pause do
    defstruct radio_url: nil, radio_title: nil, track_title: nil, playing?: true
  end

  defmodule Play_Song do
    defstruct radio_url: nil, radio_title: nil, track_title: nil, playing?: true
  end

  defmodule Stop_Song do
    defstruct radio_url: nil, radio_title: nil, track_title: nil, playing?: false
  end

  defmodule Update_Track_Title do
    defstruct radio_url: nil, radio_title: nil, track_title: nil, playing?: nil
  end
end
