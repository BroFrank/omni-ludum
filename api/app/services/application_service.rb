module ApplicationService
  class BaseError < StandardError; end

  class ValidationError < BaseError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
      super(errors.join(", "))
    end
  end

  class NotFoundError < BaseError; end
  class UnauthorizedError < BaseError; end
end
