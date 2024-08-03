defmodule CodejamWeb.Presence do
  use Phoenix.Presence,
    otp_app: :codejam,
    pubsub_server: Codejam.PubSub
end
