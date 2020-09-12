defmodule Untitled.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Untitled.Repo,
      # Start the Telemetry supervisor
      UntitledWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Untitled.PubSub},
      # Start the Endpoint (http/https)
      UntitledWeb.Endpoint,
      # Start a worker by calling: Untitled.Worker.start_link(arg)
      # {Untitled.Worker, arg}
      Untitled.Timer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Untitled.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    UntitledWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
