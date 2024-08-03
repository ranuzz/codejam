defmodule CodejamWeb.PageHTML do
  use CodejamWeb, :html

  def landing(assigns) do
    ~H"""
    <div class="mx-40 py-10">
      <div class="grid grid-cols-2 gap-4">
        <div>
          <p class="text-8xl font-extrabold text-violet-700">Codejam</p>
          <p class="text-4xl font-bold py-4">Collaborative Workspace</p>
          <p class="text-4xl font-bold ">for Developers.</p>
          <p class="py-4">
            Boost your team's coding productivity with Codejam. Discuss, plan, debug, and annotate code together in real-time, keeping your projects on track.
          </p>
          <div class="mt-4 space-x-2">
            <.primary_link_button href={~p"/users/register"}>Get Started !</.primary_link_button>
            <.primary_link_button href="#demo">View Demo</.primary_link_button>
          </div>
        </div>
        <div class="mx-20 py-10">
          <video class="w-full h-auto max-w-full border border-violet-200 rounded-lg" controls>
            <source src="/videos/note-nav.mp4" type="video/mp4" />
            Your browser does not support the video tag.
          </video>
        </div>
      </div>
      <br />
      <br />
      <div class="py-20 grid grid-cols-4 gap-4">
        <.feature_card
          icon="topic"
          title="Easy Documentation"
          content="Add and update comments collaboratively, ensuring everyone has access to the latest information."
        />
        <.feature_card
          icon="face_2"
          title="Seamless Onboarding"
          content="Create interactive walkthroughs and tutorials directly within your codebase, empowering new team members to get up to speed quickly."
        />
        <.feature_card
          icon="developer_mode"
          title="Actionable Code Reviews"
          content="Make TODOs, FIXMEs, and NOTES actionable by assigning owners and setting reminders, keeping tasks organized and accountable."
        />
        <.feature_card
          icon="partner_exchange"
          title="Real-time Collaboration"
          content="Debug faster with instant feedback and code reviews, fostering a dynamic and efficient development environment."
        />
      </div>
    </div>
    <footer class="m-4">
      <hr class="my-6 border-gray-200 sm:mx-auto dark:border-gray-700" />
      <span class="block text-sm text-gray-500 sm:text-center dark:text-gray-400">
        © 2024 Codejam. All Rights Reserved.
      </span>
    </footer>
    """
  end
end
