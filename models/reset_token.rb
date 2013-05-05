class ResetToken
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :reset_key, String, :default => { |r, p| Digest::SHA1.hexdigest([Time.now, rand].join) }
  property :type, Enum[ :login, :payment ]
  property :used, Boolean, :default => false
  property :expire_at, Datetime
  property :used_at, Datetime
  timestamps :created_at

  belongs_to :user
end
