# encoding: utf-8

class Payment
  include DataMapper::Resource

  require 'digest'

  # property <name>, <type>
  property :id, Serial
  property :token, String, :default => lambda { |r, p| [Time.now.strftime("%Y%m%d%H%M%S"), Digest::SHA1.hexdigest([Time.now, rand].join)].join }
  property :name, String
  property :type, Enum[ :inpour, :payment, :refund, :transfer, :gathering ]
  property :recipient, String
  property :pay_amount, Decimal, :scale => 2, :precision => 20
  property :grow_points, Float, :default => 0.0
  property :detail_url, String
  property :status, Enum[ :pending, :succeed, :failed, :expired]
  property :status_msg, String
  property :ended_at, DateTime
  timestamps :at

  belongs_to :user, :required => false
  belongs_to :service_provider
end
