class PrepaidCard
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :identifier, String
  property :password, BCryptHash
  property :value, Decimal, :scale => 2, :precision => 20
  property :used_at, DateTime
  property :expire_at, DateTime
  timestamps :created_at

  belongs_to :user
end
