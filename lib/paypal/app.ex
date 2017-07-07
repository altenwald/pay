defmodule Paypal.App do
  import Supervisor.Spec 

  def start(type,args) do
    children = [
      worker(Paypal.Authentication, [[type,args], [name: __MODULE__]])
    ]
    {:ok, _pid} = Supervisor.start_link(children, strategy: :one_for_one)
  end
end
