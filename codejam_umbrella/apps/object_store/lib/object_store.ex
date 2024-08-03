defmodule ObjectStore do
  @moduledoc """
  Library to save and fetch file objects
  """

  def create_bucket(config, bucket_name) do
    if !bucket_exists?(config, bucket_name) do
      case AWS.S3.create_bucket(client(config), bucket_name, %{}) do
        {:ok, _, _response} -> {:ok}
        {:error, {:unexpected_response, %{status_code: 409}}} -> {:ok}
        {:error, _} -> {:error}
      end
    else
      {:ok}
    end
  end

  def bucket_exists?(config, bucket_name) do
    case AWS.S3.head_bucket(client(config), bucket_name, %{}) do
      {:ok, _, _response} -> true
      {:error, _} -> false
    end
  end

  def put_object(config, bucket_name, bucket_path, local_path) do
    file = File.read!(local_path)
    # For large files we may have to shift to streaming
    md5 = :crypto.hash(:md5, file) |> Base.encode64()

    case AWS.S3.put_object(client(config), bucket_name, bucket_path, %{
           "Body" => file,
           "ContentMD5" => md5,
           "ContentType" => "text/plain"
         }) do
      {:ok, _, _response} -> {:ok}
      {:error, _reason} -> {:error}
    end
  end

  def get_object(config, bucket_name, path) do
    case AWS.S3.get_object(client(config), bucket_name, path) do
      {:ok, response, _} -> response["Body"]
      {:error, _} -> nil
    end
  end

  defp client(config) do
    client =
      AWS.Client.create(
        config[:access_key],
        config[:secret_key],
        config[:region]
      )

    client = %{client | port: 9000}
    client = %{client | proto: "http"}
    client = %{client | endpoint: config[:endpoint]}
    client
  end
end
