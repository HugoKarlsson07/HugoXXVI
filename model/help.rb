module Helper
  # Checks if the user is logged in, redirects to login if not.
  # @return [void]
  def user_inloggad()
    if session[:user_id].nil?
      redirect('/sessions/new')
    end
  end

  # Checks if the current user is an admin.
  # @return [Boolean] True if the user is an admin, false otherwise.
  def admin?()
    session[:user_tag_id] == 2
  end

  # Requires the user to be logged in and an admin, redirects otherwise.
  # @return [void]
  def require_admin
    redirect('/sessions/new') if session[:user_id].nil?
    redirect('/error') unless admin?()
  end
end