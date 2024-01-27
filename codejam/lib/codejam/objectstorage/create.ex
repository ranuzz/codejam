defmodule Codejam.Objectstorage.Create do
  def create do
    client =
      AWS.Client.create(
        "id",
        "key",
        "localhost"
      )

    client = %{client | port: 9000}
    client = %{client | proto: "http"}
    client = %{client | endpoint: "localhost"}

    AWS.S3.create_bucket(client, "test-bucket", %{})
  end
end
