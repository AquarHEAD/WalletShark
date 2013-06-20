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
    pay.recipient = params[:recipient] || service.service_name
    pay.pay_amount = params[:amount].to_d
    if params[:grow_points]
      pay.grow_points = params[:grow_points].to_f
    end
    if params[:detail_url]
      if params[:detail_url].start_with? "http"
        pay.detail_url = params[:detail_url]
      else
        pay.detail_url = "http://#{params[:detail_url]}"
      end
    end
    pay.status = :pending
    pay.service_provider = service
    if pay.save
      if [:refund, :transfer].include? pay.type
        if params[:user_id]
          user = User.first(:id => params[:user_id])
          user.balance += pay.pay_amount
          pay.status = :succeed
          pay.ended_at = Time.now
          pay.user = user
          pay.save
          user.grow_points += pay.grow_points
          user.save
        else
          return "Need user_id"
        end
      end
      return pay.to_json(:exclude => [:id])
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
      return pay.to_json(:exclude => [:id])
    else
      return "Requested payment not found"
    end
  end

  get :refund, :with => :token do
    service_id = params[:service_id]
    if !service_id
      halt 401
    end
    service = ServiceProvider.first(:service_id => service_id)
    if service.service_secret != params[:service_secret]
      halt 401
    end
    pay = Payment.first(:token => params[:token])
    if pay && params[:user_id] && pay.service_provider == service
      user = User.first(:id => params[:user_id])
      user.balance += pay.pay_amount
      pay.type = :refund
      pay.status = :succeed
      pay.ended_at = Time.now
      pay.user = user
      pay.save
      user.grow_points += pay.grow_points
      user.save
      return pay.to_json(:exclude => [:id])
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
    succ_call = params[:success_callback]
    if succ_call && (succ_call.start_with? "http")
      @success_callback = "#{succ_call}"
    else
      @success_callback = "http://#{succ_call}"
    end
    fail_call = params[:failure_callback]
    if fail_call && (fail_call.start_with? "http")
      @failure_callback = "#{fail_call}"
    else
      @failure_callback = "http://#{fail_call}"
    end
    @pay = Payment.first(:token => params[:payment_token])
    if @pay.status != :pending
      redirect '/user/'
    end
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
    @pay = Payment.first(:token => params[:payment_token])
    if @pay.type != :payment
      redirect '/user/'
    end
    if @user.balance >= @pay.pay_amount
      @pay.status = :succeed
      @pay.ended_at = Time.now
      @pay.save
      @user.balance -= @pay.pay_amount
      @user.grow_points += @pay.grow_points
      @user.save
      if @success_callback
        redirect @success_callback
      else
        redirect '/user/'
      end
    else
      redirect '/user/deposit/'
    end
  end

end
