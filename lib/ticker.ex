require Logger

defmodule Ticker do
  @moduledoc """
  Ticker OTP Application
  """
  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec

    Logger.info("Starting Ticker OTP Application...")

    frequency = Application.get_env(:ticker, :frequency, 60_000)

    children = [
      supervisor(Registry, [:duplicate, Ticker.Registry]),
      supervisor(Ticker.Security.Supervisor, []),
      worker(Ticker.Periodic.Periodically, [&Ticker.Periodic.Timer.quotes/1, frequency]),
      worker(Ticker.Notify.Frame, [])
    ]

    # TODO: Would be nice to start this in another place. Really shouldn't have to
    # know the processor at this point.
    processor = Application.get_env(:ticker, :processor)
    children = case processor do
      Ticker.Quote.Processor.Simulate -> [worker(Ticker.Quote.Processor.Simulate, []) | children]
      _ -> children
    end

    opts = [strategy: :one_for_one, name: Ticker.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
