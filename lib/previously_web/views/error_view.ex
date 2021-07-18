defmodule PreviouslyWeb.ErrorView do
  use PreviouslyWeb, :view

  require Logger

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  def render("500.json", assigns) do
    Logger.warn(assigns[:stack])
    %{errors: %{detail: "Internal server error"}}
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
