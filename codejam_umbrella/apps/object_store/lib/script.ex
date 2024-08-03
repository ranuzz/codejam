defmodule ObjectStore.Script do
  require Logger

  def main(args) do
    Logger.info("running object_store script")

    {parsed, _, _} =
      OptionParser.parse(args,
        strict: [method: :string, path: :string, sha: :string, bucket: :string]
      )

    {_, method} = Enum.find(parsed, fn {key, _} -> key == :method end)
    {_, path} = Enum.find(parsed, fn {key, _} -> key == :path end)
    {_, sha} = Enum.find(parsed, fn {key, _} -> key == :sha end)
    {_, bucket} = Enum.find(parsed, fn {key, _} -> key == :bucket end)

    config = %{
      :access_key => System.get_env("CODEJAM_S3_ACCESS_KEY"),
      :secret_key => System.get_env("CODEJAM_S3_SECRET_KEY"),
      :endpoint => System.get_env("CODEJAM_S3_ENDPOINT"),
      :region => System.get_env("CODEJAM_S3_REGION")
    }

    case method do
      "create_bucket" -> ObjectStore.create_bucket(config, bucket)
      "bucket_exists" -> Logger.debug("#{ObjectStore.bucket_exists?(config, bucket)}")
      "put_object" -> ObjectStore.put_object(config, bucket, sha, path)
      "get_object" -> Logger.debug("#{ObjectStore.get_object(config, bucket, sha)}")
      _ -> IO.puts("not a valid method")
    end
  end
end
