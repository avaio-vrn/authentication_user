module AuthenticationUserHelper
  def price_helper(args, &block)
    if args[:price] == 0 || args[:price].nil?
      prc = 'по запросу'.html_safe
      css = args[:css].to_s + ' price-request'
      prc_empty = true
    else
      prc = (args[:tovar].blank? ? '':'от ')
      if args[:price].is_a?(String) && args[:price].include?('от')
        args[:price].gsub!(/от\s/, '')
        prc = content_tag(:span, 'от ', class: 'price-prefix')
      end
      prc << number_to_currency(args[:price], unit: '', precision: without_kop?(args[:price]) ? 0 : 2)

      css = ['price '.freeze, (args[:css] || '')].join(' '.freeze)
      prc_empty = false
    end
    block_given? ? yield(prc, css, prc_empty) : prc
  end

  def rub_price_helper(price: , css: nil, container: nil)
    price_helper({ price: price, css: css }) do |prc, css, prc_empty|
      if prc_empty
        content_tag((container || :span), prc, class: css)
      else
        content_tag((container || :span), (prc.html_safe << content_tag(:span, '', class: 'fa fa-rub')), class: css)
      end
    end
  end

  def link_after_info
    force = config_get('main', 'force_reg_in_info_basket')
    skip_reg = (force.blank? || !force) ? { skip_reg: 1 } : {}
    authentication_user.info_basket_path(@current_basket, skip_reg)
  end

  def render_current_basket
    controller_name == 'baskets' ? nil : render('/baskets/basket')
  end
end
