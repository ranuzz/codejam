defmodule CodejamWeb.PageHTML do
  use CodejamWeb, :html

  def landing(assigns) do
    ~H"""
    <.hero_title_landing>
      <div class="flex flex-col">
        <.title>
          Codejam, the collaborative <br /> workspace for developers.
        </.title>
        <.sub_title>
          Boost your team's coding productivity with Codejam.<br />
          Discuss, plan, debug, and annotate code together in real-time, keeping your projects on track.
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
    <section class="container mx-auto py-12">
      <div class="flex flex-col items-center p-6">
        <.title>Key Features</.title>
      </div>
    </section>
    <section class="container mx-auto py-12">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div class="flex flex-col items-center p-6 rounded-lg shadow-md hover:shadow-lg hover:bg-gray-100">
          <span class="material-symbols-outlined">
            description
          </span>
          <h3 class="text-lg font-semibold mb-2">Streamlined documentation</h3>
          <p class="text-gray-600 text-center">
            Add and update comments collaboratively, ensuring everyone has access to the latest information.
          </p>
        </div>
        <div class="flex flex-col items-center p-6 rounded-lg shadow-md hover:shadow-lg hover:bg-gray-100">
          <span class="material-symbols-outlined">
            account_box
          </span>
          <h3 class="text-lg font-semibold mb-2">Seamless onboarding</h3>
          <p class="text-gray-600 text-center">
            Create interactive walkthroughs and tutorials directly within your codebase, empowering new team members to get up to speed quickly.
          </p>
        </div>
        <div class="flex flex-col items-center p-6 rounded-lg shadow-md hover:shadow-lg hover:bg-gray-100">
          <span class="material-symbols-outlined">
            description
          </span>
          <h3 class="text-lg font-semibold mb-2">Actionable code reviews</h3>
          <p class="text-gray-600 text-center">
            Make TODOs, FIXMEs, and NOTES actionable by assigning owners and setting reminders, keeping tasks organized and accountable.
          </p>
        </div>
        <div class="flex flex-col items-center p-6 rounded-lg shadow-md hover:shadow-lg hover:bg-gray-100">
          <span class="material-symbols-outlined">
            description
          </span>
          <h3 class="text-lg font-semibold mb-2">Real-time collaboration</h3>
          <p class="text-gray-600 text-center">
            Debug faster with instant feedback and code reviews, fostering a dynamic and efficient development environment.
          </p>
        </div>
      </div>
    </section>
    """
  end
end
