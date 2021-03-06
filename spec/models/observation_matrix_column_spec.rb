require 'rails_helper'

RSpec.describe ObservationMatrixColumn, type: :model, group: :matrix do

  let(:observation_matrix_column) {ObservationMatrixColumn.new}
  let(:observation_matrix) { FactoryGirl.create(:valid_observation_matrix) }
  let(:descriptor) { FactoryGirl.create(:valid_descriptor) }

  context 'validation' do
    before {observation_matrix_column.valid?}

    specify 'observation_matrix' do
      expect(observation_matrix_column.errors.include?(:observation_matrix)).to be_truthy
    end

    specify 'descriptor' do
      expect(observation_matrix_column.errors.include?(:descriptor)).to be_truthy
    end

    specify 'descriptor is unique to observation_matrix' do
      ObservationMatrixColumn.create!(observation_matrix: observation_matrix, descriptor: descriptor)
      mc = ObservationMatrixColumn.new(observation_matrix: observation_matrix, descriptor: descriptor)
      expect(mc.valid?).to be_falsey
      expect(mc.errors.include?(:descriptor_id)).to be_truthy 
    end

  end

end
