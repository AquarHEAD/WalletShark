# encoding: utf-8

class Payment
  include DataMapper::Resource

  require 'digest'

  # property <name>, <type>
  property :id, Serial
  property :token, String, :default => lambda { |r, p| Digest::SHA1.hexdigest([Time.now, rand].join) }
  property :name, String
  property :type, Enum[ :inpour, :payment, :refund, :transfer, :gathering ]
  property :recipient, String
  property :pay_amount, Decimal, :scale => 2, :precision => 20
  property :status, Enum[ :pending, :succeed, :failed, :expired]
  property :status_msg, String
  property :ended_at, DateTime
  timestamps :at

  belongs_to :user
end
