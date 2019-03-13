# -*- encoding : utf-8 -*-
module AccessDeniedExtensions
  def initialize(message = nil, action = nil, subject = nil)
    super
    raise ExceptionsErrors::AuthenticationError.new(message)
  end
end

module CanCan
	class AccessDenied
	  prepend AccessDeniedExtensions
	end
end
