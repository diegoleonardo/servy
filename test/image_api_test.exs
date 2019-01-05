defmodule ImageApiTest do
    use ExUnit.Case

    test "Responses with url image" do
        {:ok, image_url} = Servy.ImageApi.query("16x3i5")

        assert image_url == "https://images.example.com/bear.jpg"
    end

    test "Responses with error" do
        {:ok, error} = Servy.ImageApi.query("")

        assert error == nil
    end

end