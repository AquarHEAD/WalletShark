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
    pay.service_provider = service
    if pay.save
      return pay.to_json(:exclude => [:id, :user_id, :service_provider_id])
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
      return pay.to_json(:exclude => [:id, :user_id, :service_provider_id])
    else
      return "Requested payment not found"
    end
  end

  get :pay, :map => "/pay/:payment_token/?" do
    @title = "Pay"
    token = AuthToken.first(:token => session[:auth_token])
    unless token
      redirect '/user/login/'
    end
    @user = token.user
    @payment_token = params[:payment_token]
    if params[:success_callback].start_with? "http"
      @success_callback = "#{params[:success_callback]}#{return_vals}"
    else
      @success_callback = "http://#{params[:success_callback]}#{return_vals}"
    end
    if params[:failure_callback].start_with? "http"
      @failure_callback = "#{params[:failure_callback]}#{return_vals}"
    else
      @failure_callback = "http://#{params[:failure_callback]}#{return_vals}"
    end
    @pay = Payment.first(:token => params[:payment_token])
    @pay.user = @user
    @pay.save
    render 'payment/pay'
  end

  post :pay, :map => "/pay/?" do
    token = AuthToken.first(:token => session[:auth_token])
    unless token
      redirect '/user/login/'
    end
    @user = token.user
    @payment_token = params[:payment_token]
    @success_callback = params[:success_callback]
    @failure_callback = params[:failure_callback]
    @pay = Payment.first(:token => params[:payment_token])
    if @user.balance >= @pay.pay_amount || @pay.type == :refund
      @pay.status = :succeed
      @pay.ended_at = Time.now
      @pay.save
      if @pay.type == :refund
        @user.balance += @pay.pay_amount
      else
        @user.balance -= @pay.pay_amount
      end
      @user.save
      redirect @success_callback
    else
      redirect '/user/deposit/'
    end
  end

end
