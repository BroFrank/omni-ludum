class ApplicationController < ActionController::API
  include CurrentUserAudit
end
