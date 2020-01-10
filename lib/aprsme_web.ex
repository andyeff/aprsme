defmodule AprsmeWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use AprsmeWeb, :controller
      use AprsmeWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  @spec controller :: {:__block__, [], [{:import, [...], [...]} | {:use, [...], [...]}, ...]}
  def controller do
    quote do
      use Phoenix.Controller, namespace: AprsmeWeb
      import Plug.Conn
      import AprsmeWeb.Router.Helpers
      import AprsmeWeb.Gettext
      import Phoenix.LiveView.Controller
    end
  end

  @spec view :: {:__block__, [], [{:import, [...], [...]} | {:use, [...], [...]}, ...]}
  def view do
    quote do
      use Phoenix.View,
        root: "lib/aprsme_web/templates",
        namespace: AprsmeWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import AprsmeWeb.Router.Helpers
      import AprsmeWeb.ErrorHelpers
      import AprsmeWeb.Gettext

      # app-specific
      import AprsmeWeb.TimeFormatting
      import Scrivener.HTML

      import Phoenix.LiveView,
      only: [live_render: 2, live_render: 3, live_link: 1, live_link: 2,
             live_component: 2, live_component: 3, live_component: 4]
    end
  end

  @spec router :: {:__block__, [], [{:import, [...], [...]} | {:use, [...], [...]}, ...]}
  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  @spec channel :: {:__block__, [], [{:import, [...], [...]} | {:use, [...], [...]}, ...]}
  def channel do
    quote do
      use Phoenix.Channel
      import AprsmeWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
