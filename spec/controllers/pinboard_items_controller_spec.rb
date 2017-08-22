require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe PinboardItemsController, :type => :controller do
  before(:each) {
    sign_in
  }
 
  # This should return the minimal set of attributes required to create a valid
  # PinboardItem. As you add validations to PinboardItem, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    o = FactoryGirl.create(:valid_otu)
    strip_housekeeping_attributes(FactoryGirl.build(:valid_pinboard_item).attributes.merge(pinned_object_id: o.id, pinned_object_type: o.class.name, user_id: 1))
  }

  let(:invalid_attributes) {
    {pinned_object_type: "Smurf"}
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PinboardItemsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "POST create" do
    before { 
      request.env["HTTP_REFERER"] = otus_path
    }

    describe "with valid params" do
      it "creates a new PinboardItem" do
        expect {
          post :create, params: {:pinboard_item => valid_attributes}, session: valid_session
        }.to change(PinboardItem, :count).by(1)
      end

      it "assigns a newly created pinboard_item as @pinboard_item" do
        post :create, params: {:pinboard_item => valid_attributes}, session: valid_session
        expect(assigns(:pinboard_item)).to be_a(PinboardItem)
        expect(assigns(:pinboard_item)).to be_persisted
      end

      it "redirects to the previous page" do
        post :create, params: {:pinboard_item => valid_attributes}, session: valid_session
        expect(response).to redirect_to(otus_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved pinboard_item as @pinboard_item" do
        post :create, params: {:pinboard_item => invalid_attributes}, session: valid_session
        expect(assigns(:pinboard_item)).to be_a_new(PinboardItem)
      end

      it "redirects to the previous page" do
        post :create, params: {:pinboard_item => invalid_attributes}, session: valid_session
        expect(response).to redirect_to(otus_path)
      end
    end
  end

  describe "DELETE destroy" do
    before { 
      request.env["HTTP_REFERER"] = dashboard_path 
    }

    it "destroys the requested pinboard_item" do
      pinboard_item = PinboardItem.create! valid_attributes
      expect {
        delete :destroy, params: {id: pinboard_item.to_param}, session: valid_session
      }.to change(PinboardItem, :count).by(-1)
    end

    it "redirects to the pinboard_items list" do
      pinboard_item = PinboardItem.create! valid_attributes
      delete :destroy, params: {id: pinboard_item.to_param}, session: valid_session
      expect(response).to redirect_to(dashboard_path)
    end
  end

end
