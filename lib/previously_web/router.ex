defmodule PreviouslyWeb.Router do
  use PreviouslyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug PreviouslyWeb.APIAuthPlug, otp_app: :previously
  end

  pipeline :api_protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: PreviouslyWeb.APIAuthErrorHandler
  end

  scope "/api", PreviouslyWeb, as: :api do
    pipe_through :api

    resources "/registration", API.RegistrationController, singleton: true, only: [:create]
    resources "/session", API.SessionController, singleton: true, only: [:create, :delete]
    post "/session/renew", API.SessionController, :renew
  end

  scope "/api", PreviouslyWeb, as: :api do
    pipe_through [:api, :api_protected]

    # authenticated endpoints
    get "/tvshows/search", API.TVShowController, :search_imdb
    resources "/tvshows", API.TVShowController, only: [:index, :show] do
      resources "/episodes", API.EpisodeController, only: [:index, :show]
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: PreviouslyWeb.Telemetry
    end
  end
end
