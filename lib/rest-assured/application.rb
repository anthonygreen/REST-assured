require 'sinatra/base'
require 'haml'
require 'sinatra/flash'
require 'sinatra/partials'
require 'sinatra/cross_origin'
require 'rest-assured/config'
require 'rest-assured/models/double'
require 'rest-assured/models/redirect'
require 'rest-assured/models/request'
require 'rest-assured/routes/double'
require 'rest-assured/routes/redirect'
require 'rest-assured/routes/response'

module RestAssured
  class Application < Sinatra::Base

    configure do
      enable :cross_origin
    end

    before do
      response.headers['Access-Control-Allow-Origin'] = '*'
    end

    include Config

    enable :method_override

    enable :sessions
    register Sinatra::Flash

    set :public_folder, File.expand_path('../../../public', __FILE__)
    set :views, File.expand_path('../../../views', __FILE__)
    set :haml, :format => :html5

    helpers Sinatra::Partials

    helpers do
      def browser?
        request.user_agent =~ /Safari|Firefox|Opera|MSIE|Chrome/
      end
    end

    include DoubleRoutes
    include RedirectRoutes

    options "*" do
      response.headers["Allow"] = "GET, POST, OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
      response.headers["Access-Control-Allow-Origin"] = "*"
      200
    end

    %w{get post put delete patch}.each do |verb|
      send verb, /.*/ do
        Response.perform(self)
      end
    end
  end
end

