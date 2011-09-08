require "builder"

class Pivotal
  attr_reader :requestor

  def initialize(requestor)
    @requestor = requestor
  end

  def stories_to_xml(stories)
    buffer = ""

    xml = Builder::XmlMarkup.new(:target => buffer, :indent => 2)

    xml.instruct!

    xml.external_stories(:type => "array") do
      stories.each do |story|
        xml.external_story do
          xml.external_id  story["id"]
          xml.name         story["name"]
          xml.description  story["description"]
          xml.estimate     story["estimate"]

          xml.requested_by requestor
          xml.story_type   "feature"
          xml.created_at({ :type => "datetime" }, story["created_at"])
        end
      end
    end

    buffer
  end
end
