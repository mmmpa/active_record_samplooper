require 'rails_helper'

RSpec.describe SampleModel, type: :model do
  describe 'has record' do
    before :all do
      10.times { create(:sample_model) }
    end

    after :all do
      SampleModel.delete_all
    end

    describe 'direct sample' do
      it 'get SampleModel instance' do
        expect(SampleModel.sample).to be_a(SampleModel)
      end

      it 'any times, get SampleModel instance' do
        36.times { expect(SampleModel.sample).to be_a(SampleModel) }
      end
    end

    describe 'sampler sample' do
      let(:sampler) { SampleModel.sampler }

      it 'sample get once each' do
        10.times { expect(sampler.sample).to be_a(SampleModel) }
        expect(sampler.sample).to be_nil
      end

      it 'loop get any times each' do
        36.times do
          all_ids = SampleModel.pluck(:id) if all_ids.blank?

          expect(all_ids.delete(sampler.loop.id)).not_to be_nil
        end
      end

      it 'sample get destroyed raise exception' do
        sampler
        SampleModel.first.destroy
        SampleModel.first.destroy
        expect {
          10.times { sampler.sample }
        }.to raise_exception(ActiveRecordSamplooper::Gone)
      end

      it 'loop get destroyed raise exception' do
        sampler
        SampleModel.first.destroy
        SampleModel.first.destroy
        expect {
          10.times { sampler.loop }
        }.to raise_exception(ActiveRecordSamplooper::Gone)
      end
    end
  end

  describe 'no record' do
    it 'direct sample get nil' do
      expect(SampleModel.sample).to be_nil
    end

    let(:sampler) { SampleModel.sampler }

    it 'sampler sample get nil' do
      expect(sampler.sample).to be_nil
    end

    it 'sampler loop get nil' do
      expect(sampler.sample).to be_nil
    end
  end
end
