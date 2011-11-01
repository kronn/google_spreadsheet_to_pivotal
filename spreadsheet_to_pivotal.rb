require 'sinatra/base'
require './spreadsheet_stories'
require './pivotal'

class SpreadsheetToPivotal < Sinatra::Base
  $spreadsheet = SpreadsheetStories.new(
    ENV["SPREADSHEET_USERNAME"],
    ENV["SPREADSHEET_PASSWORD"],
    ENV["SPREADSHEET_KEY"],
    ENV["SPREADSHEET_MAPPING"]
  )
  $pivotal = Pivotal.new(
    ENV["SPREADSHEET_REQUESTOR"]
  )

  use Rack::Auth::Basic do |username, password|
    username == ENV["HTTP_BASIC_USERNAME"] && password == ENV["HTTP_BASIC_PASSWORD"]
  end

  get "/" do
    stories = $spreadsheet.stories

    content_type "text/xml", :charset => "utf-8"

    $pivotal.stories_to_xml(stories)
  end
end

