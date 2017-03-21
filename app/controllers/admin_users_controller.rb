class AdminUsersController < ApplicationController

	before_action :confirm_logged_in
	before_action :is_superuser

	def index
		@admin_users = AdminUser.sorted
	end

	def show
		@admin_user = AdminUser.find(params[:id])
		@tests = @admin_user.tests.order('updated_at DESC')
	end

	def new
		@admin_user = AdminUser.new
	end

	def create
		@admin_user = AdminUser.new(admin_user_params)
		if @admin_user.save
			flash[:success] = 'User created successfully.'
			redirect_to(admin_users_path)
		else
			render('new')
		end
	end

	def edit
		@admin_user = AdminUser.find(params[:id])
	end

	def update
		@admin_user = AdminUser.find(params[:id])
		if @admin_user.update_attributes(admin_user_params)
			flash[:success] = 'User updated successfully.'
			redirect_to(admin_users_path)
		else
			render('edit')
		end
	end

	def delete
		@admin_user = AdminUser.find(params[:id])
	end

	def destroy
		@admin_user = AdminUser.find(params[:id])
		@admin_user.destroy
		flash[:success] = 'User destroyed successfully.'
		redirect_to(admin_users_path)
	end

	private

	def admin_user_params
		params.require(:admin_user).permit(
				:first_name,
				:last_name,
				:section,
				:roll_number,
				:year,
				:email,
				:username,
				:password,
				:superuser
			)
	end

end
