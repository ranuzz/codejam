defmodule Codejam.ObjectStore do
  def write(content, sha, project_id, organization_id, ext) do
    config = Application.get_env(:codejam, Codejam.Blob.Config)
    ObjectStore.create_bucket(config, organization_id)

    source_file_path = "/tmp/" <> sha <> ext
    highlightes_file_path = "/tmp/" <> sha <> ".html"

    storage_source_file_path = project_id <> "/" <> sha
    storage_highlightes_file_path = storage_source_file_path <> ".html"

    File.write(source_file_path, content)
    SyntaxHighlighter.highlight(source_file_path, highlightes_file_path)

    ObjectStore.put_object(config, organization_id, storage_source_file_path, source_file_path)

    ObjectStore.put_object(
      config,
      organization_id,
      storage_highlightes_file_path,
      highlightes_file_path
    )
  end

  def read(sha, project_id, organization_id) do
    config = Application.get_env(:codejam, Codejam.Blob.Config)
    ObjectStore.get_object(config, organization_id, project_id <> "/" <> sha <> ".html")
  end

  def read_raw(sha, project_id, organization_id) do
    config = Application.get_env(:codejam, Codejam.Blob.Config)
    ObjectStore.get_object(config, organization_id, project_id <> "/" <> sha)
  end
end
