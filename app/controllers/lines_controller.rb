class LinesController < ApplicationController

	before_action :confirm_logged_in
	before_action :is_superuser

	def edit
		@line = Line.where(:program_id => params[:id])
	end

	def update
		if params[:commit] == 'Finish'
			@lines = params[:lines]
			@lines.each do |key,values|
				@line = Line.find(key)
				@line.update_attributes(values.permit(:address,:data,:code))
			end
			redirect_to(programs_path)
		elsif params[:commit] == 'Re-assemble'
			@program = Line.find(params[:lines].first.first).program
			@program.lines.delete_all
			Sic.pass1(@program.source)
			Sic.pass2(@program.id)
			@program.object_program = ""
			File.open("object_program.txt").each do |line|
		    	@program.object_program +=  line
		    end
		    @program.save
			redirect_to(programs_path)
		elsif params[:commit] == 'Add a line'
			@lines = params[:lines]
			@lines.each do |key,values|
				@line = Line.find(key)
				@line.update_attributes(values.permit(:address,:data,:code))
			end
			@program = Line.find(params[:lines].first.first).program
			Line.create(:program_id => @program.id, :data => "")
			redirect_to(edit_line_path(@program.id))
		elsif params[:commit] == 'Delete last line'
			@lines = params[:lines]
			@lines.each do |key,values|
				@line = Line.find(key)
				@line.update_attributes(values.permit(:address,:data,:code))
			end
			@program = Line.find(params[:lines].first.first).program
			@program.lines.last.destroy
			redirect_to(edit_line_path(@program.id))
		end
	end

end
