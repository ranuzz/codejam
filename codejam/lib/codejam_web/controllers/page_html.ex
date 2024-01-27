defmodule CodejamWeb.PageHTML do
  use CodejamWeb, :html

  def landing(assigns) do
    ~H"""
    <.hero_title_landing>
      <div class="flex flex-col">
        <.title>
          Real-Time Collaboration Platform for <br />Understanding Code Repositories.
        </.title>
        <.sub_title>
          <ul>
            <li>Debugging on demand: Get instant help from teammates, live in your code editor.</li>
            <li>
              Onboard like a pro: Collaborative exploration empowers new engineers to hit the ground running.
            </li>
            <li>
              Docs built from the source: Generate living documentation directly from your code discussions.
            </li>
            <li>
              Seamless bug reporting: File tickets right from your code, with all context captured.
            </li>
          </ul>
        </.sub_title>
        <div class="mt-10">
          <.link_button href={~p"/users/register"} class="accent">Get Started !</.link_button>
          <.link_button href="#demo" class="secondary">View Demo</.link_button>
        </div>
        <div id="demo" class="mt-10">
          <div class="mockup-window border bg-base-300">
            <div class="flex justify-center bg-base-200">
              <video controls>
                <source src="/videos/codejam-demo-1.mp4" type="video/mp4" />
              </video>
            </div>
          </div>
        </div>
      </div>
    </.hero_title_landing>
    """
  end
end
