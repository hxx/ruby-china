class Oauth::AuthorizedApplicationsController < Doorkeeper::ApplicationController
  before_filter :authenticate_resource_owner!

  def destroy
    Doorkeeper::AccessToken.revoke_all_for params[:id].to_i, current_resource_owner
    redirect_to oauth_applications_url, notice: I18n.t(:notice, scope: [:doorkeeper, :flash, :authorized_applications, :destroy])
  end
end

