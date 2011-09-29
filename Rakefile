task :default => :configure

desc "setup bridging app on heroku"
task :setup => :configure do
  require 'heroku'
  heroku = Heroku::Auth.client
  include SetupHelper

  puts ''
  app_name = find_or_create_app
  config = read_local_config

  # push the app itself to heroku
  heroku.git "push heroku master"

  puts <<-EOT

  It seems like we could set everything up on heroku.

  You should test that the app gives you XML back

    open http://#{app_name}.heroku.com/

  In order to complete the installation, you need to add the integration
  to Pivotal

  From the "Configure Integrations" page, add an "Other" integration.

    * Name:                Product Backlog
    * Basic Auth username: #{config['http_basic']['username']}
    * Basic Auth password: #{config['http_basic']['password']}
    * Base URL:  "The base-url prepended to the ID for external linking"
    * Import API URL:      http://#{app_name}.heroku.com/
    * Active:              Yes

  From the "More" menu of Pivotal Tracker you should see "Product Backlog"

  EOT
end

desc "configure bridging app"
task :configure => 'config.yml' do
  require 'heroku'
  heroku = Heroku::Auth.client
  include SetupHelper

  puts ''
  app_name = find_or_create_app(heroku)
  config = read_local_config

  # add the local config variables to the application
  heroku.add_config_vars(app_name, {
    "SPREADSHEET_USERNAME"  => config['spreadsheet']['username'],
    "SPREADSHEET_PASSWORD"  => config['spreadsheet']['password'],
    "SPREADSHEET_KEY"       => config['spreadsheet']['key'],
    "SPREADSHEET_MAPPING"   => config['spreadsheet']['mapping'],
    "SPREADSHEET_REQUESTOR" => config['spreadsheet']['requestor'],
    "HTTP_BASIC_USERNAME"   => config['http_basic']['username'],
    "HTTP_BASIC_PASSWORD"   => config['http_basic']['password']
  })
  puts "  configuration sent to heroku"
  puts ''
end

file "config.yml" => "config.yml.example" do
  puts <<-EOT

  I've been expecting you.

    Please copy config.yml.example and fill in your details.

  Once this is done, run "rake setup" to setup a bridging app on heroku.
  This implies that you have an account on heroku an setup your system.

  Further instructions on how to link Pivotal Tracker to this app will be
  displayed after everything is set up.

  EOT
end

module SetupHelper
  def find_or_create_app(heroku)
    # check wether we have an app on heroku and create one if necessary
    if git_remote = heroku.git("config remote.heroku.url")
      app_name = git_remote.scan(/.*:([-a-zA-Z0-9]+)\.git/).flatten.first
      puts "  found heroku app named '#{app_name}'"
    else
      puts '  creating app on heroku'
      app_name = heroku.create(nil, {:stack => 'bamboo-mri-1.9.2'})
      heroku.git "remote add heroku git@#{heroku.host}:#{app_name}.git"
      puts "  #{app_name} created and git remote added"
    end

    app_name
  end

  def read_local_config
    require 'pathname'
    require 'yaml'
    fn = Pathname.new("./config.yml").expand_path

    if fn.exist?
      YAML.load_file(fn)
    else
      nil
    end
  end
end
