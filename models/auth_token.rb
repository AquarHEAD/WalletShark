# encoding: utf-8

class AuthToken
  include DataMapper::Resource

  require 'digest'

  # property <name>, <type>
  property :id, Serial
  property :token, String, :default => lambda { |r, p| Digest::SHA1.hexdigest([Time.now, rand].join) }
  property :status, Enum[ :fresh, :authed, :dropped, :expired ], :default => :fresh
  property :expire_at, DateTime
  property :used_at, DateTime
  timestamps :created_at

  # belongs_to :user, :required => false, :default => User.first()
  has 1, :user, :required => false
  belongs_to :service_provider
end
