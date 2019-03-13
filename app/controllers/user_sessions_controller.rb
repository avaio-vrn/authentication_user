# -*- encoding : utf-8 -*-
class UserSessionsController < ApplicationController
  skip_before_filter :require_login, except: [:destroy]

  def new
    if params[:provider] == 'yandex'.freeze
      redirect_to authentication_user.auth_at_provider_path(provider: :yandex)
    elsif params[:provider] == 'mailru'.freeze
      redirect_to authentication_user.auth_at_provider_path(provider: :mailru)
    else
      @user = User.new

      respond_to do |format|
        format.html
        format.js
      end
    end
  end

  def create
    basket_id = session[:basket_id]
    if @user = login(params[:email],params[:password],params[:remember_me])
      @admin_panel = Admin::Panel::Base.new() if current_user&.admin_less?
      flash[:notice] = 'Вход успешно выполнен'

      session[:basket_id] = basket_id
      @current_basket.update_attributes(
        name: @user.fio,
        contacts: @user.email,
        address: @user.address,
        user_id: @user.id
      )

      if current_user.user?
        redirect_to authentication_user.user_url(@user)
      else
        redirect_to :root
      end
    else
      user = User.where(email: params[:email]).first
      if user.blank?
        raise ExceptionsErrors::InvalidLogin.new
      elsif user.activation_state == 'pending'.freeze
        raise ExceptionsErrors::NeedActivateAccount
      else
        raise ExceptionsErrors::InvalidLogin.new
      end
    end
  end

  def destroy
    logout
    redirect_to :root, notice: 'Выход выполнен!'
  end
end

