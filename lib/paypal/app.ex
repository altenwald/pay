defmodule Paypal.App do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    children = [worker(Paypal.Authentication, [])]
    Supervisor.start_link(children,  [strategy: :one_for_one, name: __MODULE__])
  end
end