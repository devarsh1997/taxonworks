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

describe ContainerItemsController, :type => :controller do
  before(:each) {
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # ContainerItem. As you add validations to ContainerItem, be sure to
  # adjust the attributes here as well.
  # let(:valid_attributes) {
  #   skip("Add a hash of attributes valid for your model")
  # }
  let(:valid_attributes) { strip_housekeeping_attributes(FactoryGirl.build(:valid_container_item).attributes) }

  # let(:invalid_attributes) {
  #   skip("Add a hash of attributes invalid for your model")
  # }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ContainerItemsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before {
    request.env['HTTP_REFERER'] = list_otus_path # logical example
  }

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ContainerItem" do
        expect {
          post :create, params: {container_item: valid_attributes}, session: valid_session
        }.to change(ContainerItem, :count).by(2) # !! not one, as the parent enclosing container has to be created as well
      end

      it "assigns a newly created container_item as @container_item" do
        post :create, params: {container_item: valid_attributes}, session: valid_session
        expect(assigns(:container_item)).to be_a(ContainerItem)
        expect(assigns(:container_item)).to be_persisted
      end

      it "redirects to :back" do
        post :create, params: {container_item: valid_attributes}, session: valid_session
        expect(response).to redirect_to(list_otus_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved container_item as @container_item" do
        # post :create, params: {container_item: invalid_attributes}, session: valid_session
        allow_any_instance_of(ContainerItem).to receive(:save).and_return(false)
        post :create, params: {container_item: {invalid: 'params'}}, session: valid_session
        expect(assigns(:container_item)).to be_a_new(ContainerItem)
      end

      it "re-renders the :back template" do
        # post :create, params: {container_item => invalid_attributes}, session: valid_session
        allow_any_instance_of(ContainerItem).to receive(:save).and_return(false)
        post :create, params: {container_item: {invalid: 'params'}}, session: valid_session
        expect(response).to redirect_to(list_otus_path)
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      # let(:new_attributes) {
      #   skip("Add a hash of attributes valid for your model")
      # }
      let(:update_params) {ActionController::Parameters.new({container_id: '1'}).permit(:container_id)}

      it "updates the requested container_item" do
        container_item = ContainerItem.create! valid_attributes
        # put :update, params: {id => container_item.to_param, :container_item => new_attributes}, session: valid_session
        # container_item.reload
        # skip("Add assertions for updated state")
        expect_any_instance_of(ContainerItem).to receive(:update).with(update_params)
        put :update, params: {id: container_item.to_param, container_item: update_params}, session: valid_session
      end

      it "assigns the requested container_item as @container_item" do
        container_item = ContainerItem.create! valid_attributes
        put :update, params: {id: container_item.to_param, container_item: valid_attributes}, session: valid_session
        expect(assigns(:container_item)).to eq(container_item)
      end

      it "redirects to :back" do
        container_item = ContainerItem.create! valid_attributes
        put :update, params: {id: container_item.to_param, container_item: valid_attributes}, session: valid_session
        expect(response).to redirect_to(list_otus_path)
      end
    end

    describe "with invalid params" do
      it "assigns the container_item as @container_item" do
        container_item = ContainerItem.create! valid_attributes
        # put :update, params: {id => container_item.to_param, :container_item => invalid_attributes}, session: valid_session
        allow_any_instance_of(ContainerItem).to receive(:save).and_return(false)
        put :update, params: {id: container_item.to_param, container_item: {invalid: 'parms'}}, session: valid_session
        expect(assigns(:container_item)).to eq(container_item)
      end

      it "re-renders the :back template" do
        container_item = ContainerItem.create! valid_attributes
        # put :update, params: {id => container_item.to_param, :container_item => invalid_attributes}, session: valid_session
        allow_any_instance_of(ContainerItem).to receive(:save).and_return(false)
        put :update, params: {id: container_item.to_param, container_item: {invalid: 'parms'}}, session: valid_session
        expect(response).to redirect_to(list_otus_path)
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested container_item" do
      container_item = ContainerItem.create! valid_attributes
      expect {
        delete :destroy, params: {id: container_item.to_param}, session: valid_session
      }.to change(ContainerItem, :count).by(-1)
    end

    it "redirects to :back" do
      container_item = ContainerItem.create! valid_attributes
      delete :destroy, params: {id: container_item.to_param}, session: valid_session
      expect(response).to redirect_to(list_otus_path)
    end
  end

end
