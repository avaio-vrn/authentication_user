# == Schema Information
#
# Table name: basket_items
#
#  id             :integer          not null, primary key
#  basket_id      :integer
#  tovar_model_id :integer
#  count          :integer
#  price          :decimal(7, 2)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class BasketItemsController < ApplicationController
  authorize_resource
  layout nil

  def create
    if params[:tovar_model].nil? && params[:order_count].blank?
      count = 1
    else
      count = order_count_from_params
    end
    if  count > 0
      @basket = current_basket
      @basket.save!(validate: false)
      session[:basket_id] = @current_basket.id
      if params[:models]
        params[:models].split(',').each_slice(2).to_a.each do |e|
          @basket_item = @basket.add_basket_item(e[0], e[1].to_i)
          @basket_item.save!(validate: false)
        end
      else
        @basket_item = @basket.add_basket_item(params[:tovar_model], count)
      end
      @basket_item.save!(validate: false)
    end
    respond_to do |format|
      format.js { render 'create', layout: nil }
    end
  end

  def update
    @basket_item = BasketItem.find(params[:id])
    respond_to do |format|
      @basket_item.count = order_count_from_params
      if params[:basket_item_count] =~ /\d*/ && params[:basket_item_count].to_i > 0
      @basket_item.count = params[:basket_item_count].to_i
      if @basket_item.save!(validate: false)
        @current_basket = @basket_item.basket
        format.js { render 'update', layout: nil }
      else
        format.js { render inline: 'alert("Что-то не так. Сообщите менеджеру.");', layout: nil }
      end
      else
        format.js { render nothing: true, layout: nil }
      end
    end
  end

  def destroy
    @basket_item = BasketItem.find(params[:id])
    @current_basket = @basket_item.basket
    @basket_item.destroy

    respond_to do |format|
      if @current_basket.total_count.zero?
        @current_basket.destroy
        flash[:alert] = 'Ваш заказ пуст.'.freeze
        format.js { render js: "window.location.href='"+root_path+"'" }
      else
        format.js { render 'destroy', layout: false }
      end
    end
  end

  private

  def order_count_from_params
    params[:basket_item_count] ? params[:basket_item_count].to_i : 1
  end
end
