class SerialsController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :require_sign_in
  before_action :set_serial, only: [:show, :edit, :update, :destroy]

  # GET /serials
  # GET /serials.json
  def index
    @recent_objects = Serial.order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  def list
    @serials = Serial.order(:id).page(params[:page])
  end

  # GET /serials/1
  # GET /serials/1.json
  def show
    # TODO: put computation here for displaying alternate values?
  end

  # GET /serials/new
  def new
    @serial = Serial.new
  end

  # GET /serials/1/edit
  def edit
  end

  # POST /serials
  # POST /serials.json
  def create
    @serial = Serial.new(serial_params)

    respond_to do |format|
      if @serial.save
        format.html { redirect_to @serial, notice: "Serial '#{@serial.name}' was successfully created." }
        format.json { render action: 'show', status: :created, location: @serial }
      else
        format.html { render action: 'new' }
        format.json { render json: @serial.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /serials/1
  # PATCH/PUT /serials/1.json
  def update
    respond_to do |format|
      if @serial.update(serial_params)
        format.html { redirect_to @serial, notice: 'Serial was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @serial.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /serials/1
  # DELETE /serials/1.json
  def destroy
    @serial.destroy
    respond_to do |format|
      format.html { redirect_to serials_url }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to serials_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to serial_path(params[:id])
    end
  end

  # @todo Some extra code here, str defined with extra param, used in label_html. Verify correct.
  def autocomplete
    @serials = Serial.find_for_autocomplete(params)

    data = @serials.collect do |t|
      str = ApplicationController.helpers.serial_autocomplete_tag(t, params[:term])
      { id: t.id,
        label: ApplicationController.helpers.serial_tag(t),
        response_values: {
          params[:method] => t.id
        },
        label_html: str
      }
    end

    render json: data
  end

  # GET /serials/download
  def download
    send_data Serial.generate_download(Serial.all), type: 'text', filename: "serials_#{DateTime.now}.csv"
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_serial
    @serial = Serial.find(params[:id])
    @recent_object = @serial
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def serial_params
    params.require(:serial).permit(:name,
                                   :publisher,
                                   :place_published,
                                   :primary_language_id,
                                   :first_year_of_issue,
                                   :last_year_of_issue,
                                   alternate_values_attributes: [
                                     :id,
                                     :value,
                                     :type,
                                     :language_id,
                                     :alternate_value_object_type,
                                     :alternate_value_object_id,
                                     :alternate_value_object_attribute,
                                     :_destroy
                                   ])
  end
end
