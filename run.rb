$: << 'lib'
require 'all'

Backblaze.configure do |config_map|
  config_map.merge!(
    :application_key => "***REMOVED***",
    :account_id => "***REMOVED***",
    :debug_http => true,
    :log_level => :debug
  )
end

api_session = Backblaze::Api::Session.new Backblaze.config
auth_request = Backblaze::Api::AuthorizeAccountRequest.new api_session
auth_request.send
