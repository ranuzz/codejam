defmodule Codejam.Files.S3 do
  @doc """
  For every organization there should be a bucket in S3
  s3://<organization_id>

  For every project and branch there should be a folder
  s3://<organization_id>/<project_id>/<branch>/

  For every snapshot_id create a folder and sync all files
  s3://<organization_id>/<project_id>/<branch>/snapshot_id/<files>
  """
  def upload_snapshot(_snapohsot_id, _organization_id) do
  end

  @doc """
  Given an inode use the snapshot_id/project_id/organization_id
  put a single file in s3 bucket
  """
  def put_file(_inode_id, _organization_id) do
  end

  @doc """
  Given an inode use the snapshot_id/project_id/organization_id
  to create the full file path and fetch the content
  """
  def get_file(_inode_id, _organization_id) do
  end
end
