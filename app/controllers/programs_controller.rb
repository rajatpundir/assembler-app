class ProgramsController < ApplicationController

  before_action :confirm_logged_in
  before_action :is_superuser

  # READ ACTIONS
  def index
    @programs = Program.sorted
  end
  
  def show
    @program = Program.find(params[:id])
    @lines = @program.lines
  end

  def score
    @program_name = Program.find(params[:format]).name
    @program = params[:format]
    @users = AdminUser.where("id IN (SELECT \"tests\".admin_user_id FROM \"tests\" WHERE (program_id=#{@program}))").sorted
  end

  # CREATE ACTIONS
  def new
    @program = Program.new
  end

  def create
    @program = Program.new(:name=> params[:program][:name],:position => params[:program][:position],:source => params[:program][:source], :visible => params[:program][:visible], :addressing => params[:program][:addressing])
      if @program.save
      Sic.pass1(@program.source)
      Sic.pass2(@program.id)
      File.open("object_program.txt").each do |line|
        temp = line.split("^")
        temp.delete("")
        line = temp.join("^")
        @program.object_program +=  line
      end
      @program.save
      flash[:success] = "Program created successfully."
      redirect_to(programs_path)
    else
      flash[:danger].now = "Program error."
      render 'new'
    end
  end

  # UPDATE ACTIONS
  def edit
    @program = Program.find(params[:id])
  end

  def update
    @program = Program.find(params[:id])
    if @program.update_attributes(program_params)
      redirect_to (edit_line_path)
    else
      render 'edit'
    end
  end

  # DELETE ACTIONS
  def delete
    @program=Program.find(params[:id])
  end

  def destroy
    @program=Program.find(params[:id])
    @program.destroy
    flash[:success] = "Program '#{@program.name}' deleted successfully."
    redirect_to(programs_path)
  end

private

  def program_params
    params.require(:program).permit(:name,:position,:visible,:addressing,:source)
  end

end