# encoding: utf-8

class User
  include DataMapper::Resource

  property :id, Serial
  property :username, String, :required => true, :unique => true
  property :nickname, String, :required => true
  property :email, String, :required => true, :unique => true
  property :login_pass, BCryptHash, :required => true
  property :payment_pass, BCryptHash, :required => true
  property :realname, String, :required => true
  property :id_number, String, :required => true
  property :bind_phone, String
  property :sec_question, String
  property :sec_answer, String
  property :actived, Boolean, :default => true
  property :grow_points, Float, :default => 0.0
  property :balance, Decimal, :scale => 2, :precision => 20, :default => 0.00
  timestamps :at

  has n, :payment
end
