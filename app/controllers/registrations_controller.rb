# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, :redirect_unless_admin, only: %i[new create]
  skip_before_action :require_no_authentication

  def create
    super do
      if current_user.try(:admin)
        unless %w[district_admin panchayat_admin phone_caller].include?(resource.role)
          resource.role = 'phone_caller'
          resource.save
        end
      elsif current_user.try(:district_admin)
        unless %w[panchayat_admin phone_caller].include?(resource.role)
          resource.role = 'phone_caller'
          resource.save
        end
      end
    end
  end

  private

  def redirect_unless_admin
    unless current_user.try(:admin?) || current_user.try(:district_admin?)
      flash[:alert] = 'Access Denied! Only Admins are Allowed Access'
      redirect_to root_path
    end
  end

  def sign_up(_resource_name, _resource)
    true
  end

  def after_sign_up_path_for(_resource)
    new_user_registration_path
  end
end
