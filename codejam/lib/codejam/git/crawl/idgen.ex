defmodule Codejam.Git.Crawl.Idgen do
  def create_id do
    Integer.to_string(:rand.uniform(4_294_967_296), 32)
  end
end
