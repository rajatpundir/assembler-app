class AccessController < ApplicationController

	before_action :confirm_logged_in, :except => [:login, :attempt_login, :logout]
	before_action :is_superuser, :except => [:login, :attempt_login, :logout]

	def menu
		@username = session[:username]
		redirect_to(programs_path)
	end

	def login
	end

	def attempt_login
		if params[:username].present? && params[:password].present?
			found_user = AdminUser.where(:username => params[:username]).first
			if found_user
				authorized_user = found_user.authenticate(params[:password])
			end
		end

		if authorized_user
			session[:user_id] = authorized_user.id
			session[:username] = authorized_user.username
			redirect_to(admin_path)
		else
			flash.now[:danger] = "Invalid username or password."
			render('login')
		end
	end

	def logout
		session[:user_id] = nil
		session[:username] = nil
		flash[:success] = 'You are logged out.'
		redirect_to(access_login_path)
	end

end
