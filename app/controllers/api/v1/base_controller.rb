# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      before_action :set_current_user_ivar

      private

      def set_current_user_ivar
        @current_user = current_user
      end
    end
  end
end
