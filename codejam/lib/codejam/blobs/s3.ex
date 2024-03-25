defmodule Codejam.Blobs.S3 do
  def client do
    config = Application.get_env(:codejam, Codejam.Blob.Config)

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

  def create_bucket(bucket_name) do
    if !bucket_exists?(bucket_name) do
      case AWS.S3.create_bucket(client(), bucket_name, %{}) do
        {:ok, _, _response} -> {:ok}
        {:error, {:unexpected_response, %{status_code: 409}}} -> {:ok}
        {:error, _} -> {:error}
      end
    else
      {:ok}
    end
  end

  def bucket_exists?(bucket_name) do
    case AWS.S3.head_bucket(client(), bucket_name, %{}) do
      {:ok, _, _response} -> true
      {:error, _} -> false
    end
  end

  def put_object(bucket_name, bucket_path, local_path) do
    file = File.read!(local_path)
    # For large files we may have to shift to streaming
    md5 = :crypto.hash(:md5, file) |> Base.encode64()

    case AWS.S3.put_object(client(), bucket_name, bucket_path, %{
           "Body" => file,
           "ContentMD5" => md5,
           "ContentType" => "text/plain"
         }) do
      {:ok, _, _response} -> {:ok}
      {:error, _reason} -> {:error}
    end
  end

  def get_object(bucket_name, path) do
    case AWS.S3.get_object(client(), bucket_name, path) do
      {:ok, response, _} -> {:ok, response["Body"]}
      {:error, _} -> {:error}
    end
  end
end
