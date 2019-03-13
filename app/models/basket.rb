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

class Basket < ActiveRecord::Base
  before_save :contacts_set, if: proc { contacts.blank? && !(phone.blank? && email.blank?) }
  after_save :update_user, unless: proc { phone.blank? && email.blank? }

  belongs_to :user
  has_many :basket_items, dependent: :destroy

  attr_accessible :name, :message, :contacts, :address, :user_id, :status, :phone, :email, :without_check, :pay_type, :delivery_type,
    :delivery_type2, :delivery_cost, :org_name, :inn, :delivery_message, :pay_message
  attr_accessor :phone, :email, :without_check, :delivery_type2, :delivery_cost, :org_name, :inn

  validates_presence_of :name
  validates_presence_of :phone, if: proc { |r| !r.without_check && ::Configuration.loaded_get('main', 'cart_contacts').include?('phone') }
  validates_presence_of :contacts, if: proc {|r| !r.without_check && !r.new_record? && r.phone.blank? && r.email.blank? && r.contacts.blank? }
  validates_length_of :name, maximum: 100, too_long: 'Поле для имени максимум 100сим.'
  validates_length_of :contacts, maximum: 100, too_long: 'Контакты должны быть до 100сим.'
  validates :contacts, format: { with: /(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,}))|(^[+]?[78][\s|(]?\d{3}[\s|)]?\d{3}[-|\s]?\d{2}[-|\s]?\d{2}$)/,
                                 message: 'видимо вы ошиблись в написании телефона или элек.почты' }, allow_blank: true
  validates :email, format: {  with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})/,
                               message: "видимо вы ошиблись в написании элек.почты" }, allow_blank: true
  validates :phone, format: { with: /\A[+]?[78]?\s?[\s|(]?\d{3}[\s|)]?\s?\d{3}[-|\s]?\d{2}[-|\s]?\d{2}\z/,
                              message: 'видимо вы ошиблись в написании телефона' }, allow_blank: true
  validates_length_of :message, maximum: 200, too_long: 'Сообщение должно быть до 200сим.'
  validates_length_of :address, maximum: 250, too_long: 'Адрес должен быть до 250сим.'

  scope :ordering, -> { order('created_at DESC')}
  scope :last_baskets, ->(user_id, count=2) { where(user_id: user_id).where('status >=0').order('created_at DESC').limit(count) }

  def content_name
    'Корзина'.freeze
  end

  def to_s
    "#{I18n.l(created_at, format: :form)} / <b>#{name}</b> / #{contacts}".html_safe
  end

  def status_humanize
    if (0..3).include? status
      I18n.t("activerecord.attributes.basket.humanize_status.s#{status}")
    else
      "Неизв.статус. Сообщите менеджеру".freeze
    end
  end

  def pay_type_humanize
    case self.pay_type
    when 1; 'Наличными при получении'
    when 2; 'Банк.картой сейчас через Яндекс.Касса'
    when 3; 'Счет для организации'
    when 99; 'Другое'
    end
  end

  def delivery_type_humanize
    case self.delivery_type
    when 1; 'Самовывоз'
    when 2; 'Доставка ТК "DPD"'
    when 3; 'Доствка курьером'
    when 99; 'Другое'
    end
  end

  def contacts_view
    if contacts.blank?
      phone_from_user.blank? ? email : phone_from_user
    else
      contacts
    end
  end

  def name_from_user
    user_id.blank? ? name : user.fio
  end

  def phone_from_user
    user_id.blank? ? phone : user.phone
  end

  def add_basket_item(id, count=1)
    tovar = TovarModel.find(id)
    price = tovar.stock? ? tovar.tovar_stocks.price : tovar.price_in_currency
    item = basket_items.where(tovar_model_id: id, price: price || 0)
    if item.blank?
      current_item = self.basket_items.build(tovar_model_id: id, price: price || 0, count: count)
    else
      item = item.first
      item.count += count
      current_item = item
    end
    current_item
  end

  def empty?
    basket_items.blank?
  end

  def total_sum
    if basket_items.any? {|item| item.price.to_f.zero? }
      0
    else
      basket_items.map{|item| item.count*item.price }.inject(:+)&.round(2)
    end
  end

  def total_count
    basket_items.map{|item| item.count }.inject(:+) || 0
  end

  def count
    basket_items.size
  end

  def delivery_cities
    @cities || @cities = DpdApi::Geography.cities_cash_pay
  end

  private

  def contacts_set
    self.contacts = phone.blank? ? email : phone
  end

  def update_user
    return if user_id.blank?
    user = self.user
    user.fio = self.name if user.fio.blank?
    user.phone = self.phone if user.phone.blank?
    user.email = self.email if user.email.blank?
    user.save if user.changed? && user.valid?
  end
end
