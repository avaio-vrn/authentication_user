# -*- encoding : utf-8 -*-
class MailerBasket < ActionMailer::Base
  def prepare(basket, opt={})
    @biz_info ||= opt['biz_info'] || BizInfo.new
    @send_params = basket
    to ||= @send_params.contacts
    if !opt[:recepient].nil?
      if !to.nil? && to.match(/\A([^@\s[\/\\]]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
        mail(from: "site@#{domain}", to: to, subject: get_subject(opt[:zakaz]))
      else
        nil
      end
    else
      mail(from: "site@#{domain}", to: opt[:to] || email_for_form.split(',').first, subject: get_subject(opt[:zakaz]))
    end
  end

  private

  def get_subject(zakaz)
    "[#{domain}] #{zakaz ? 'Заказ' : 'Вопрос'}"
  end

  def domain
    @biz_info.domain
  end

  def email_for_form
    @biz_info.email_for_form
  end
end
