# encoding: utf-8

class ResetToken
  include DataMapper::Resource

  require 'digest'

  # property <name>, <type>
  property :id, Serial
  property :token, String, :default => lambda { |r, p| Digest::SHA1.hexdigest([Time.now, rand].join) }
  property :type, Enum[ :login, :payment ]
  property :used, Boolean, :default => false
  property :expire_at, DateTime
  property :used_at, DateTime
  timestamps :created_at

  belongs_to :user
end
