require "rails_helper"

RSpec.describe "Genres", type: :request do
  describe "POST /genres" do
    it "creates a genre and redirects when name is valid" do
      expect {
        post "/genres", params: { genre: { name: "Strategy" } }
      }.to change(Genre, :count).by(1)

      expect(response).to redirect_to(genres_path)
    end

    it "does not create a genre when name is blank" do
      expect {
        post "/genres", params: { genre: { name: "" } }
      }.not_to change(Genre, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "does not create a genre when name is a duplicate" do
      create(:genre, name: "Strategy")

      expect {
        post "/genres", params: { genre: { name: "Strategy" } }
      }.not_to change(Genre, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /genres/:id/edit" do
    it "returns 200" do
      genre = create(:genre, name: "Party")
      get "/genres/#{genre.id}/edit"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /genres/:id" do
    it "updates the genre name and redirects" do
      genre = create(:genre, name: "Party")
      patch "/genres/#{genre.id}", params: { genre: { name: "Party Games" } }
      expect(genre.reload.name).to eq("Party Games")
      expect(response).to redirect_to(genres_path)
    end
  end

  describe "DELETE /genres/:id" do
    it "removes the genre and redirects" do
      genre = create(:genre, name: "Trivia")
      expect {
        delete "/genres/#{genre.id}"
      }.to change(Genre, :count).by(-1)
      expect(response).to redirect_to(genres_path)
    end
  end

  describe "GET /genres" do
    it "returns 200" do
      get "/genres"
      expect(response).to have_http_status(:ok)
    end

    it "lists genres by name" do
      create(:genre, name: "Wargame")
      create(:genre, name: "Abstract")

      get "/genres"

      expect(response.body).to match(/Abstract.*Wargame/m)
    end
  end
end
