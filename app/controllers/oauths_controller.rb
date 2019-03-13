class OauthsController < ApplicationController
  skip_before_filter :require_login

  def oauth
    login_at(params[:provider])
  end

  def callback
    provider = params[:provider]
    begin
      @user = login_from(provider)
    rescue OAuth2::Error => e
      @error = true
    end

    if @user
      redirect_to root_path, notice: "Вход с помощью #{provider.titleize}!"
    elsif !@error
      query_attr = user_attrs(@provider.user_info_mapping, @user_hash)
      raise ExceptionsErrors::InvalidAccountAccess.new if query_attr.blank?
      @current_user = User.where(query_attr).first
      unless @current_user.blank?
        add_provider_to_user(provider)
        @user = login_from(provider)
        @user.activate! if Rails.application.config.sorcery.submodules.include?(:user_activation)

        redirect_to root_path, notice: "Вход с помощью #{provider.titleize}!"
      else
        raise ExceptionsErrors::InvalidAccountAccess.new
      end
    else
      raise ExceptionsErrors::InvalidAccountAccess.new
    end
  end
end
