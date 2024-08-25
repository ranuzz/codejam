defmodule CodejamWeb.UserLoginLive do
  use CodejamWeb, :live_view

  def render(assigns) do
    ~H"""
    <section class="bg-gray-50">
      <div class="flex flex-col items-center justify-center px-6 mx-auto md:h-screen lg:py-0">
        <a href="/" class="flex items-center mb-6 text-2xl font-semibold text-violet-900">
          <img class="w-12 h-12 mt-2" src="/images/logo.png" alt="logo" /> Codejam
        </a>
        <div class="w-full bg-white rounded-lg shadow dark:border md:mt-0 sm:max-w-md xl:p-0 dark:bg-gray-800 dark:border-gray-700">
          <div class="p-6 space-y-4 md:space-y-6 sm:p-8">
            <h1 class="text-xl font-bold leading-tight tracking-tight text-gray-900 md:text-2xl dark:text-white">
              Welcome back
            </h1>
            <div class="flex justify-between">
              <.github_auth_oauth_button github_oauth_url={@oauth_url} />
              <button
                type="button"
                class="text-xs text-white bg-[#4285F4] hover:bg-[#4285F4]/90 focus:ring-4 focus:outline-none focus:ring-[#4285F4]/50 rounded-lg px-5 py-2.5 text-center inline-flex items-center me-2 mb-2"
              >
                <svg
                  class="w-4 h-4 me-2"
                  aria-hidden="true"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="currentColor"
                  viewBox="0 0 18 19"
                >
                  <path
                    fill-rule="evenodd"
                    d="M8.842 18.083a8.8 8.8 0 0 1-8.65-8.948 8.841 8.841 0 0 1 8.8-8.652h.153a8.464 8.464 0 0 1 5.7 2.257l-2.193 2.038A5.27 5.27 0 0 0 9.09 3.4a5.882 5.882 0 0 0-.2 11.76h.124a5.091 5.091 0 0 0 5.248-4.057L14.3 11H9V8h8.34c.066.543.095 1.09.088 1.636-.086 5.053-3.463 8.449-8.4 8.449l-.186-.002Z"
                    clip-rule="evenodd"
                  />
                </svg>
                Sign in with Google
              </button>
            </div>
            <div class="relative flex items-center">
              <div class="flex-grow border-t border-gray-400"></div>
              <span class="flex-shrink mx-4 text-gray-400">or</span>
              <div class="flex-grow border-t border-gray-400"></div>
            </div>

            <.form
              as={nil}
              for={@form}
              id="login_form"
              action={~p"/users/log_in"}
              phx-update="ignore"
              class="space-y-4 md:space-y-6"
            >
              <.input field={@form[:email]} type="email" label="Email" required />
              <.input field={@form[:password]} type="password" label="Password" required />
              <div class="flex items-center justify-between">
                <div class="flex items-start">
                  <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
                </div>
                <.link
                  href={~p"/users/reset_password"}
                  class="text-sm font-medium text-violet-600 hover:underline dark:text-violet-500"
                >
                  Forgot password?
                </.link>
              </div>
              <.button
                phx-disable-with="Signing in..."
                class="w-full text-white bg-violet-600 hover:bg-violet-700 focus:ring-4 focus:outline-none focus:ring-violet-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center"
              >
                Sign in
              </.button>
              <p class="text-sm font-light text-gray-500 dark:text-gray-400">
                Don’t have an account yet?
                <.link
                  navigate={~p"/users/register"}
                  class="font-medium text-violet-600 hover:underline dark:text-violet-500"
                >
                  Sign up
                </.link>
              </p>
            </.form>
          </div>
        </div>
      </div>
    </section>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    socket =
      socket
      |> assign(:form, form)
      |> assign(:oauth_url, Codejam.Github.get_auth_authorization_url("login"))

    {:ok, socket, temporary_assigns: [form: form]}
  end
end
