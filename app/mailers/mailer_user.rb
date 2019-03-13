# -*- encoding : utf-8 -*-
class MailerUser < ActionMailer::Base
  def activation_needed_email(user)
    @biz_info = BizInfo.new
    @user = user
    @url  = "#{host}/users/#{user.activation_token}/activate"
    mail(from: from, to: user.email, subject: I18n.t('mail.activation_needed', domain: domain))
  end

  def activation_success_email(user)
    @biz_info = BizInfo.new
    @user = user
    @url  = "#{host}/login"
    mail(from: from, to: user.email, subject: I18n.t('mail.activation_success', domain: domain))
  end

  def reset_password_email(user)
    @biz_info = BizInfo.new
    @user = User.find user.id
    @url  = authentication_user.edit_password_reset_url(@user.reset_password_token)
    mail(from: from, to: user.email, subject: I18n.t('mail.reset_password', domain: domain))
  end

  private

  def from
    "site@#{domain}".freeze
  end

  def host
    [@biz_info.protocol, domain].join('://')
  end

  def domain
    @biz_info.domain
  end
end
