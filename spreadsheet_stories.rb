require "google_spreadsheet"

class SpreadsheetStories
  attr_reader :worksheet, :mapping

  def initialize(user, pass, key, mapping)
    @mapping = mapping.to_s.split('-')
    session = GoogleSpreadsheet.login(user, pass)
    @worksheet = session.spreadsheet_by_key(key).worksheets[0]
  end

  def stories
    # get all the remote changes
    worksheet.reload

    # ignore the first row
    rows = 2..31

    # parse the mapping
    cols = mapping.inject({}) do |hash, col|
      hash[col] = mapping.index(col)+1 if col.length > 0
      hash
    end

    # extract data
    rows.to_a.map do |row|
      story = {}
      cols.each do |name, col|
        story[name] = worksheet[row,col]
      end
      story if story['id'].to_i > 0
    end.compact
  end
end
