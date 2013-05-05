class User
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :username, String
  property :email, String
  property :login_pass, BCryptHash
  property :payment_pass, BCryptHash
  property :realname, String
  property :id_number, String
  property :bind_phone, String
  property :sec_question, String
  property :sec_answer, String
  property :actived, Boolean, :default => true
  property :grow_points, Float
  property :balance, Decimal, :scale => 2, :precision => 20
  timestamps :at
end
