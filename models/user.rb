class User
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :username, String
  property :email, String
  property :password, BCryptHash
  property :realname, String
  property :id_number, String
  property :bind_phone, String
  property :sec_question, String
  property :sec_answer, String
  property :actived, Boolean, :default => true
end
