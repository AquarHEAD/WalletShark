# encoding: utf-8

# Helper methods defined here can be accessed in any controller or view in the application

WalletShark::App.helpers do
  def vip_level(grow_points)
    if grow_points >= 500000
      return "VIP6"
    elsif grow_points >= 150000
      return "VIP5"
    elsif grow_points >= 50000
      return "VIP4"
    elsif grow_points >= 20000
      return "VIP3"
    elsif grow_points >= 5000
      return "VIP2"
    elsif grow_points >=1000
      return "VIP1"
    else
      return "VIP0"
    end
  end
end
