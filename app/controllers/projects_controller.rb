class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :images]
  before_action :correct_user, only: [:download]
  before_action :is_project_owner, only: [:destroy]





  # GET /projects
  # GET /projects.json
  def index
    # Only index projects of the current user
    @projects = current_user.projects
    @public_projects = Project.where(public: true)
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    # New jobs can be created from the projects view
    @job = Job.new
  end

  # GET /projects/new
  def new
    @project = Project.new
    @job = @project.jobs.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    # First, create the project itself
    @user = current_user
    @project = @user.projects.create(project_params)
    # Then, start the job
    job = Job.create(job_params[:job].merge(:project_id => @project.id))
    @user_job = UserJob.perform_later(job)

    respond_to do |format|
      if @project.save
        format.html { redirect_to user_project_path(current_user, @project), notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_project
      @project = Project.find(params[:id])
    end

    def correct_user
      @project = Project.find(params[:project_id])
      redirect_to :back if @project.user != current_user
    end

    def is_project_owner
      @project = Project.find(params[:id])
      redirect_to :back if @project.user != current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:job, :name, :model_id)
    end

    def job_params
      params.require(:project).permit(:job => [:status , :user_id, :arguments])
    end
end