class EmployeesController < ApplicationController
  before_action :set_employee, only: [
    :show, :edit, :update, :destroy,
    :edit_avatar, :update_avatar, :delete_avatar
  ]

  # GET /employee
  # GET /employee.json
  def index
    @employees = Employee.all
  end

  # GET /employee/1
  # GET /employee/1.json
  def show
  end

  # GET /employee/new
  def new
    @employee = Employee.new
  end

  # GET /employee/1/edit
  def edit
  end

  # POST /employee
  # POST /employee.json
  def create
    @employee = Employee.new(employee_params)

    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: 'Employee was successfully created.' }
        format.json { render :show, status: :created, location: @employee }
      else
        format.html { render :new }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /employee/1
  # PATCH/PUT /employee/1.json
  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to @employee, notice: 'Employee was successfully updated.' }
        format.json { render :show, status: :ok, location: @employee }
      else
        format.html { render :edit }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employee/1
  # DELETE /employee/1.json
  def destroy
    @employee.destroy
    respond_to do |format|
      format.html { redirect_to employees_path, notice: 'Employee was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def edit_avatar
  end

  def update_avatar
    respond_to do |format|
      if @employee.update(update_avatar_params)
        format.html { redirect_to edit_avatar_path, notice: 'アイコンを変更しました' }
        format.json { render :show, status: :ok, location: edit_avatar_path }
      else
        binding.pry
        format.html { render :edit_avatar }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete_avatar
    respond_to do |format|
      if @employee.update({remove_avatar: true})
        format.html { redirect_to edit_avatar_path, notice: 'アイコンを削除しました' }
        format.json { render :show, status: :ok, location: edit_avatar_path }
      else
        format.html { render :edit_avatar }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_employee
      @employee = Employee.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def employee_params
      params.require(:employee).permit(
        :last_name,
        :first_name,
        :last_kana_name,
        :first_kana_name,
        :age
      )
    end

    def edit_avatar_params
      params.require(:employee).permit(
        :employee_id,
        :avatar
      )
    end

    # アイコン変更
    def update_avatar_params
      params.require(:employee).permit(
        :avatar
      )
    end

end
