# encoding: utf-8

class ServiceProvider
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :service_id, String
  property :service_secret, String
  property :service_name, String
  
end
