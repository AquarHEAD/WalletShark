class AuthToken
  include DataMapper::Resource

  require 'digest'

  # property <name>, <type>
  property :id, Serial
  property :auth_key, String, :default => { |r, p| Digest::SHA1.hexdigest([Time.now, rand].join) }
  property :status, Enum[ :fresh, :authed, :expired ]
  property :expire_at, Datetime
  property :used_at, Datetime
  timestamps :created_at

  belongs_to :user
end
