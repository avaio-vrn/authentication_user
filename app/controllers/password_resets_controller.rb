# -*- encoding : utf-8 -*-
class PasswordResetsController < ApplicationController
  skip_before_filter :require_login

  def new
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user
      if @user.deliver_reset_password_instructions!
        redirect_to(root_path, notice: 'Инструкции по восстановлению пароля отправлены на ваш email.')
      else
       redirect_to(root_path, alert: 'Данные не смогли отправиться. Связитесь со службой поддержки.')
      end
    else
      flash.now[:alert] = 'Пользователь с таким email не найден.'.freeze
      render action: "new"
    end
  end

  def edit
    @user = User.load_from_reset_password_token(params[:id])
    @token = params[:id]
    not_authenticated unless @user
  end

  def update
    @token = params[:token]
    @user = User.load_from_reset_password_token(params[:token])
    not_authenticated and return unless @user

    @user.password_confirmation = params[:user][:password_confirmation]

    if @user.change_password!(params[:user][:password])
      redirect_to(root_path, :notice => 'Пароль был обновлен.')
    else
      render action: "edit"
    end
  end
end
