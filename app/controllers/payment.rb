# encoding: utf-8

WalletShark::App.controllers :payment do
  get :new do
    service_id = params[:service_id]
    if !service_id
      halt 401
    end
    service = ServiceProvider.first(:service_id => service_id)
    if service.service_secret != params[:service_secret]
      halt 401
    end
    pay = Payment.new
    pay.name = params[:name]
    pay.type = params[:type].to_sym
    pay.recipient = params[:recipient]
    pay.pay_amount = params[:amount].to_d
    pay.status = :pending
    if pay.save
      return pay.to_json(:exclude => [:id, :user_id])
    else
      return pay.errors
    end
  end

  get :info, :with => :token do
    service_id = params[:service_id]
    if !service_id
      halt 401
    end
    service = ServiceProvider.first(:service_id => service_id)
    if service.service_secret != params[:service_secret]
      halt 401
    end
    pay = Payment.first(:token => params[:token])
    if pay
      return pay.to_json(:exclude => [:id, :user_id])
    else
      return "Requested payment not found"
    end
  end

end
