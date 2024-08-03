defmodule GithubClient.Script do
  require Logger

  def main(args) do
    Logger.info("running github_client script")

    {parsed, _, _} =
      OptionParser.parse(args,
        strict: [method: :string, owner: :string, repo: :string, sha: :string]
      )

    {_, method} = Enum.find(parsed, fn {key, _} -> key == :method end)
    {_, owner} = Enum.find(parsed, fn {key, _} -> key == :owner end)
    {_, repo} = Enum.find(parsed, fn {key, _} -> key == :repo end)
    {_, sha} = Enum.find(parsed, fn {key, _} -> key == :sha end)
    token = System.get_env("CODEJAM_GITHUB_ACCESS_TOKEN")

    case method do
      "list_repo" ->
        GithubClient.list_repo(token)

      "get_authorization_url" ->
        Logger.debug("#{GithubClient.get_authorization_url("state")}")

      "get_access_token" ->
        Logger.debug("#{inspect(GithubClient.get_access_token(%{code: "", state: ""}))}")

      "user_info" ->
        Logger.debug("#{inspect(GithubClient.user_info(token))}")

      "search_repo" ->
        Logger.debug("#{inspect(GithubClient.search_repo(token))}")

      "get_latest_commit_hash" ->
        Logger.debug("#{inspect(GithubClient.get_latest_commit_hash(token, owner, repo))}")

      "get_commit" ->
        Logger.debug("#{inspect(GithubClient.get_commit(token, owner, repo, sha))}")

      "get_tree" ->
        Logger.debug("#{inspect(GithubClient.get_tree(token, owner, repo, sha))}")

      "get_blob" ->
        Logger.debug("#{inspect(GithubClient.get_blob(token, owner, repo, sha))}")

      _ ->
        IO.puts("not a valid method")
    end
  end
end
