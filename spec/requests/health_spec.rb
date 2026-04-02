require "rails_helper"

RSpec.describe "Application layout", type: :request do
  it "serves the health check endpoint" do
    get "/up"
    expect(response).to have_http_status(:ok)
  end

  it "renders a nav element" do
    get "/"
    expect(response.body).to include("<nav")
  end

  it "renders a main element" do
    get "/"
    expect(response.body).to include("<main")
  end
end
