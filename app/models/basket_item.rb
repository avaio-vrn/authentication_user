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

class BasketItem < ActiveRecord::Base
  belongs_to :basket
  belongs_to :tovar_model

  attr_accessible :basket_id, :count, :price, :tovar_model_id

  validates :price, :count, presence: true
  validates :count, numericality: { greater_than: 0 }

  def to_s
    'ошибка' if tovar_model.blank? || tovar_model.tovar.blank?
    [tovar_model.tovar.content_name, tovar_model.content_name].join('<br>')
  end

  def sum
    count * price
  end

end
