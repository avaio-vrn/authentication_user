# == Schema Information
#
# Table name: baskets
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :string(100)
#  contacts   :string(100)
#  address    :string(255)
#  message    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BasketsController < ApplicationController
  load_and_authorize_resource
  before_filter :set_actions, if: proc { request.format.symbol == :html && current_user&.admin_less? }
  before_filter :check_basket_items, only: [:info, :thanks, :index, :create], if: proc{ !current_user || !current_user&.admin_less? }
  before_filter :redirect_to_registration, only: :info

  def index
    if current_user&.admin_less?
      @list_pages = Admin::ListPages.new do |l|
        l.controller_name = controller_name
        l.action_name = action_name
        l.list = @baskets.ordering.page(params[:page])
      end
      render 'admin_index'
    else
      redirect_to authentication_user.basket_url(@current_basket)
    end
  end

  def show
    @title = 'Ваша корзина заказа'
    raise ExceptionsErrors::AuthenticationError.new if !current_user && @current_basket.id != @basket.id
    if @current_basket.id != params[:id].to_i
      @prev_basket = Basket.find(params[:id])
      raise ExceptionsErrors::InvalidAccountAccess.new if current_user&.user? && @prev_basket.user_id != current_user.id
      render 'show_prev'
    else
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1970 00:00:00 GMT"
    end
  end

  def registration
    raise ExceptionsErrors::InvalidAccountAccess.new if current_user&.user? && @current_basket.user_id != current_user.id
    @user = User.new
  end

  def info
    raise ExceptionsErrors::InvalidAccountAccess.new if current_user&.user? && @current_basket.user_id != current_user.id

    @form_css_class = 'js__validate order-form'
    @form_css_class.concat(' js__form-with-terms') if ::Configuration.loaded_get('main', 'terms_of_service')
  end

  def send_order
    render layout: 'application'
  end

  def thanks
    if @current_basket.update_attributes(params[:basket].merge(status: 0))
      # begin
        customer_mail = MailerBasket.prepare(@current_basket, { zakaz: true, recepient: true })
        customer_mail.deliver if customer_mail

        #TODO rm config.main_info
        emails = @biz_info&.email_for_form || Rails.application.config.main_info.email_order
        emails.split(',').each do |to|
          MailerBasket.prepare(@current_basket, { zakaz: true, to: to }).deliver
        end

        @last_basket = @current_basket
        @current_basket = Basket.new
        session.delete(:basket_id)

        if params[:pay_order]
          render 'payment'
        else
          redirect_to authentication_user.send_order_baskets_url
        end
      # rescue
      #   redirect_to :root, alert: 'Возникла ошибка. Сообщите, пожалуйста, менеджеру.'
      # end
    else
      flash.now[:alert] = 'Некоторые поля формы заполнены неверно.'
      render action: 'info'
    end
  end

  def destroy
    current_basket = Basket.find(params[:r_id] || params[:id])
    current_basket.destroy
    respond_to do |format|
      format.html { redirect_to baskets_url }
      format.json { render json: current_basket }
    end
  end

  def list
    @baskets = if current_user.manager?
                 Basket.ordering
               else
                 current_user.baskets.ordering
               end
    render 'index'
  end

  def report
    params[:date_start] = params[:date_start].blank? ? Time.now : Time.parse(params[:date_start])
    params[:date_end] = params[:date_end].blank? ? Time.now : Time.parse(params[:date_end])
    @current_baskets = Basket.where(created_at: params[:date_start]..params[:date_end]).ordering
  end

  private

  def check_basket_items
    if @current_basket.basket_items.blank?
      if action_name == 'thanks'.freeze
        redirect_to root_path, alert: 'Ваш заказ пуст.'
      else
        redirect_to(request.env['HTTP_REFERER'] || root_path, alert: 'Ваш заказ пуст.')
      end
    end
  end

  def redirect_to_registration
    redirect_to  authentication_user.registration_basket_url(@current_basket) unless (current_user || params['skip_reg'])
  end

  def set_actions
    @admin_panel = Admin::Panel::Base.new(@basket || Basket, { namespace: ''})
    @admin_panel.model_engine = 'authentication_user'
    @admin_panel.from(controller_name, action_name)
  end
end
