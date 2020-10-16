defmodule PickrWeb.PageController do
  use PickrWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
