# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  skip_before_filter :require_login, only: [:index, :new, :create, :activate]
  before_filter :set_actions, if: proc { request.format.symbol == :html && current_user&.admin_less? }

  def index
    if current_user&.admin?
      @list_pages = Admin::ListPages.new do |l|
        l.controller_name = controller_name
        l.action_name = action_name
        l.list = User.ordering.page(params[:page])
      end
      render 'admin_index'
    else
      raise ExceptionsErrors::AuthenticationError.new
    end
  end

  def show
    if current_user
      @user = User.find(params[:id])
      if !current_user.manager? && @user.id != current_user.id
        raise ExceptionsErrors::InvalidAccountAccess.new
      end
    else
      raise ExceptionsErrors::AuthenticationError.new
    end
  end

  def new
    @user = User.new
    respond_to do |format|
      format.html { render 'new_edit' }
      format.js
    end
  end

  def edit
    if current_user
      @user = User.find(params[:id])
      if !current_user.admin_less? && @user.id != current_user.id
        raise ExceptionsErrors::InvalidAccountAccess.new
      end
      render 'new_edit', locals: { form_partial: 'form_update' }
    else
      raise ExceptionsErrors::AuthenticationError.new
    end
  end

  def create
    raise LackAuthorityError if current_user&.user?
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        redir = current_user&.admin_less? ? authentication_user.users_path : :root
        format.html { redirect_to redir, notice: view_context.h_flash_msg(:activate) }
      else
        format.html { render action: 'new', template: '/application/new_edit' }
      end
    end
  end

  def create_from_cart
    raise LackAuthorityError if current_user&.user?
    @user = User.new(fio: params[:user][:fio], email: params[:user][:email], without_pass: true)

    basket_id = session[:basket_id]
    respond_to do |format|
      if @user.save

        @user.activate!
        @user.update_attributes(password: params[:user][:password], password_confirmation: params[:user][:password])
        login(@user.email, params[:user][:password])

        session[:basket_id] = basket_id
        @current_basket.update_attributes!(
          name: @user.fio || 'Покупатель',
          contacts: @user.email,
          address: @user.address,
          user_id: @user.id,
          without_check: true
        )
        format.html { redirect_to authentication_user.info_basket_path(id: basket_id) }
      else
        format.html { render '/baskets/registration' }
      end
    end
  end

  def update
    if current_user
      @user = User.find(params[:id])
      if !current_user.manager? && @user.id != current_user.id
        raise ExceptionsErrors::InvalidAccountAccess.new
      end
      @user.legal_hash_set(params)

      respond_to do |format|
        if @user.update_attributes(params[:user])
          format.html { redirect_to authentication_user.user_path(@user), notice: view_context.h_flash_msg(:update) }
        else
          @user.legal_hash_set(params)
          format.html { render action: 'edit', template: '/application/new_edit', locals: { form_partial: 'form_update' } }
        end
      end
    else
      raise ExceptionsErrors::AuthenticationError.new
    end
  end

  def destroy
    if current_user
      @user = User.find(params[:id])
      @user.destroy

      respond_to do |format|
        format.html { redirect_to authentication_user.users_url }
      end
    else
      raise ExceptionsErrors::AuthenticationError.new
    end
  end

  def activate
    if (@user = User.load_from_activation_token(params[:id]))
      @user.activate!
      redirect_to(login_path, notice: view_context.h_flash_msg(:successe))
    else
      not_authenticated
    end
  end

  private

  def set_actions
    @user = User.find(params[:id]) if params[:id]
    @admin_panel = Admin::Panel::Base.new(@user || User, { namespace: ''})
    @admin_panel.from(controller_name, action_name)
    @admin_panel.model_engine = 'authentication_user'
  end
end
