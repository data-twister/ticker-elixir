defmodule Ticker.Frame do
  @derive [Poison.Encoder]
  defstruct [
    :open,
    :high,
    :low,
    :close
  ]

  def quotes_to_frame([]), do: %Ticker.Frame{}
  def quotes_to_frame(quotes) when is_list(quotes) do
    Enum.reduce(quotes, %Ticker.Frame{open: hd(quotes), high: hd(quotes), low: hd(quotes), close: hd(quotes)}, fn(q, frame) ->
      %{frame | high: max_quote(frame.high, q), low: min_quote(frame.low, q), close: q}
    end)
  end

  def frames_to_frame([]), do: %Ticker.Frame{}
  def frames_to_frame(frames) when is_list(frames) do
    Enum.reduce(frames, %Ticker.Frame{open: hd(frames).open, high: hd(frames).high, low: hd(frames).low, close: hd(frames).close}, fn(f, frame) ->
      %{frame | high: max_quote(frame.high, f.high), low: min_quote(frame.low, f.low), close: f.close}
    end)
  end

  defp min_quote(x,y) do
    case x.l <= y.l do
      true -> x
      _ -> y
    end
  end

  defp max_quote(x,y) do
    case x.l >= y.l do
      true -> x
      _ -> y
    end
  end

end
