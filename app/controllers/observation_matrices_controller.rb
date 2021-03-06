class ObservationMatricesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_matrix, only: [:show, :edit, :update, :destroy, :row]

  # GET /observation_matrices
  # GET /observation_matrices.json
  def index
    @recent_objects = ObservationMatrix.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /observation_matrices/1
  # GET /observation_matrices/1.json
  def show
  end

  def list
    @observation_matrices = ObservationMatrix.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # GET /observation_matrices/new
  def new
    @observation_matrix = ObservationMatrix.new
  end

  # GET /observation_matrices/1/edit
  def edit
  end

  # POST /observation_matrices
  # POST /observation_matrices.json
  def create
    @observation_matrix = ObservationMatrix.new(observation_matrix_params)

    respond_to do |format|
      if @observation_matrix.save
        format.html { redirect_to @observation_matrix, notice: 'Matrix was successfully created.' }
        format.json { render :show, status: :created, location: @observation_matrix }
      else
        format.html { render :new }
        format.json { render json: @observation_matrix.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /observation_matrices/1
  # PATCH/PUT /observation_matrices/1.json
  def update
    respond_to do |format|
      if @observation_matrix.update(observation_matrix_params)
        format.html { redirect_to @observation_matrix, notice: 'Matrix was successfully updated.' }
        format.json { render :show, status: :ok, location: @observation_matrix }
      else
        format.html { render :edit }
        format.json { render json: @observation_matrix.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /observation_matrices/1
  # DELETE /observation_matrices/1.json
  def destroy
    @observation_matrix.destroy
    respond_to do |format|
      format.html { redirect_to observation_matrices_url, notice: 'Matrix was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def autocomplete
    @observation_matrices = ObservationMatrix.where(project_id: sessions_current_project_id).where('name like ?', "#{params[:term]}%")
    data                  = @observation_matrices.collect do |t|
      {id:              t.id,
       label:           t.name, 
       gid: t.to_global_id.to_s,
       response_values: {
         params[:method] => t.id
       },
       label_html:      t.name 
      }
    end
    render :json => data
  end

  def search
    if params[:id].blank?
      redirect_to observationMatrices_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to observationMatrix_path(params[:id])
    end
  end

  # GET /observation_matrices/:id/row.json?otu_id=1
  def row
    @descriptors = @observation_matrix.descriptors
    @otu = Otu.find(params[:otu_id])
  end

  private

  def set_matrix
    @observation_matrix = ObservationMatrix.find(params[:id])
  end

  def observation_matrix_params
    params.require(:observation_matrix).permit(:name)
  end
end
