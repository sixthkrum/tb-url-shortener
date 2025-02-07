# README

The resources folder contains documentation for the APIs (Swagger documentation, Postman collection and Bruno collection)

To run this application:
1. Clone this to your machine
2. Switch to the root of the git repo
3. Make sure you have an appropriate Ruby version manager installed, this project uses 3.3.6
4. Run `bundle install` to get the gems installed
5. Run `rails db:migrate` to get the database initialized
6. To run tests: `rails t`
7. To run the application: `rails s`
   1. The application opens to the "sign in" page, click the "sign up" button to create an account
   2. After signing up the application redirects to the "sign in" page, enter credentials there
   3. After signing in the application redirects to the URL shortening page, enter the URLs you want to shorten there
   4. The URL shortening page has a button to get to the listing page and to logout, the listing page has a list of all the shortened URLs
