require "test_helper"

class ShortenedUrlsControllerTest < ActionDispatch::IntegrationTest
  # not putting asserts in setup to prevent them from running multiple times
  # tests for Sessions Controller should be written separately and are not in scope
  setup do
    user = users(:one)

    post(session_url,
         params: { user: { password: "password12345", email_address: user.email_address } },
         headers: { accept: "application/json" },
         as: "application/json")

    @jwt_token = JSON.parse(@response.body)["data"]["token"]
  end

  test "can successfully create shortened URLs" do
    original_url = "https://google.com"
    post(shortened_urls_path,
         params: { shortened_url: { original_url: original_url } },
         headers: { accept: "application/json", authorization: "Bearer #{@jwt_token}" },
         as: "application/json")

    # Shortened URL is created successfully
    assert_response(:success)

    shortened_url = JSON.parse(@response.body)["data"]["shortened_url"]["shortened_url"]

    # Shortened URL is a valid HTTP URL
    assert(ShortenedUrl.valid_http_url?(shortened_url))

    get(shortened_url)

    # Shortened URL gives a redirect response
    assert_response(:redirect)

    # Shortened URL's redirect is the same as the original URL
    assert_equal(@response.headers["location"], original_url)
  end

  test "cannot create shortened URLs for non HTTP URLs" do
    original_url = "google.com"

    post(shortened_urls_path,
         params: { shortened_url: { original_url: original_url } },
         headers: { accept: "application/json", authorization: "Bearer #{@jwt_token}" },
         as: "application/json")

    # Shortened URL could not be created because of the original URL not being a valid HTTP URL
    assert_response(:bad_request, "Shortened URLs could not be created")
    assert_equal(JSON.parse(@response.body)["errors"][0]["message"], "Original url is not a valid HTTP URL")
  end
end
