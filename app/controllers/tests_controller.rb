class TestsController < ApplicationController

	before_action :confirm_logged_in

	def index
		@programs = Program.visible.sorted
	end

	def edit
		@line = Line.where(:program_id => params[:id])
		@program = Program.find(@line.first.program_id)
		@program_name = @program.name
		@check = @program.addressing
		@line.each do |line|
			line.code = ""
		end
	end

	def update
		if params[:commit] == 'Submit'
			@submitted_lines = params[:lines].to_a
			@program = Program.find(params[:program_id])
			@lines = @program.lines.to_a
			score = 0
			count = @lines.size - 1
			while (count >= 0)
				if @submitted_lines[count].last[:code] == @lines[count].code
					score += 1
				end
				count -= 1
			end 
			@program = Program.find(params[:program_id])
			# Note to self: do something about line breaks, try using regex to split instead.
			@correct_object_program = @program.object_program.split("\n")
			@correct_object_program.map { |e|  e.gsub!(/[^0-9A-Za-z]/,'')}
			@correct_object_program.delete("")
			@users_object_program = params[:object_program][:object_program].split("\r\n")
			@users_object_program.map { |e|  e.gsub!(/[^0-9A-Za-z]/,'')}
			@users_object_program.delete("")
			# Note to self: all elements of both variables should rather be captilalized here
			# or they will create a problem in future.
			@correct_object_program.each do |cline|
				@users_object_program.each do |uline|
					if cline == uline
						score += 1
						break
					end
				end
			end
			score = (score*100)/(@program.lines.size + @correct_object_program.size)
			if @test = Test.where("program_id=#{@program.id} and admin_user_id=#{session[:user_id]}").first
				@test.score = score
			else
				@test = Test.new(:program_id => @program.id, :admin_user_id => session[:user_id], :score=> score)
			end
			if @test.save
				flash[:success] = "Test submitted successfully."
			end
			redirect_to(tests_path)
		end	
	end

end
