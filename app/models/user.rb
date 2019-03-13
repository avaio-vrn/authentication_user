# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  before_save :set_defaults
  before_validation :convert_requisites#, unless: @legal_hash.blank?

  attr_accessible :legal, :fio, :email, :phone, :address, :password, :role,
    :with_message, :password_confirmation, :remember_me, :without_pass, :authentications_attributes
  attr_accessor :with_message, :without_pass

  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end

  has_many :authentications, dependent: :destroy
  has_many :baskets, dependent: :destroy
  accepts_nested_attributes_for :authentications

  validates_presence_of :email, :fio
  validates_uniqueness_of :email
  validates :email, format: {  with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})/,
                               message: 'неверный формат! верно, например, mail@temsys.ru' }, allow_blank: true
  validates :phone, format: { with: /\A[+]?[78]?\s?[\s|(]?\d{3}[\s|)]?\s?\d{3}[-|\s]?\d{2}[-|\s]?\d{2}\z/,
                              message: 'видимо вы ошиблись в написании телефона' }, allow_blank: true
  validates_length_of :fio, :email, :address, maximum: 250
  validates_length_of :with_message, maximum: 500
  validates_length_of :password, minimum: 5, allow_blank: true
  validates_confirmation_of :password
  validate :valid_requisites, unless: :new_record?
  validate :without_password, if: :new_record?

  scope :ordering, -> { order(:fio) }

  ROLES = %w[admin manager user]
  LEGAL = { ru: [[0, 'Физическое лицо'],[1, 'Юридическое лицо']],
            en: [[0, 'Individual'],[1, 'Legal entity']] }

  def self.filter_query_get(params)
    if params[:column_name] == 'id'
      self.where(id: params[:value]).ordering
    else
      arel = self.arel_table
      attr = arel[params[:column_name]]
      self.where(attr.matches("%#{params[:value]}%")).ordering
    end
  end

  def to_s
    email
  end

  def content_name
    email
  end

  def admin?
    role == "admin".freeze
  end

  def admin_less?
    role == "admin_less".freeze || role == "admin".freeze
  end

  def manager?
    role != 'user' && (role == 'manager' || role == 'admin' || role == 'admin_less')
  end

  def user?
    role == 'user'
  end

  def legal_hash_set(params)
    @legal_hash ||= Hash.new
    %w[inn kpp ogrn bank bic correspondent_account checking_account].each do |field|
      if params.has_key?(field.to_s)
        @legal_hash.merge!(field.to_sym => params[field.to_s])
      end
    end
  end

  def inn
    (@legal_hash || legal_hash_get)[:inn]
  end

  def kpp
    (@legal_hash || legal_hash_get)[:kpp]
  end

  def ogrn
    (@legal_hash || legal_hash_get)[:ogrn]
  end

  private

  def bank
    (@legal_hash || legal_hash_get)[:bank]
  end

  def bic
    (@legal_hash || legal_hash_get)[:bic]
  end

  def correspondent_account
    (@legal_hash || legal_hash_get)[:correspondent_account]
  end

  def checking_account
    (@legal_hash || legal_hash_get)[:checking_account]
  end

  def valid_requisites
    if self.legal && role == 'user'
      %w[inn kpp ogrn bank bic correspondent_account checking_account].each do |field|
        if self.send(field).blank?
          errors.add(field.to_sym, I18n.t(:blank, scope: [:activerecord, :errors, :models, :user,
                                                          :attributes, field.to_sym]))
        end
      end
    end
  end

  def without_password
    if !self.without_pass && self.password.blank?
      errors.add(field.to_sym, I18n.t(:blank, scope: [:activerecord, :errors, :models, :user,
                                                      :attributes, :password]))
    end
  end

  def set_defaults
    self.role = "user" if role.blank?
  end

  def convert_requisites
    self.info = @legal_hash.to_s
  end

  def legal_hash_get
    #{ :inn => '' }
    if info.is_a? Hash
      @legal_hash = info
    else
      @legal_hash = {}
      hash_from_info =  Hash[(info.gsub(/[{}\\]/,'')||'').split(",").collect{|x| x.strip.split("=>")}]
      %w[inn kpp ogrn bank bic correspondent_account checking_account].each do |field|
        value = hash_from_info[":#{field}"].strip[1..-2] if hash_from_info.has_key?(":#{field}")
        @legal_hash.merge!(field.to_sym => (value || ''))
      end
    end
    @legal_hash
  end
end
