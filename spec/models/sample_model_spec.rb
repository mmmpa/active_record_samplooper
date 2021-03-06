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

      it 'get SampleModel instance from relation' do
        expect(SampleModel.select(:id, :name).sample).to be_a(SampleModel)
      end
    end


    describe 'from sampler' do
      let(:sampler) { SampleModel.sampler }

      describe 'sampler pick' do
        it 'any times, get SampleModel instance' do
          36.times { expect(sampler.sample).to be_a(SampleModel) }
        end
      end

      it 'pick get once each' do
        10.times { expect(sampler.pick).to be_a(SampleModel) }
        expect(sampler.pick).to be_nil
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
          10.times { sampler.pick }
        }.to raise_exception(ActiveRecordSamplooper::Gone)
      end

      it 'loop get destroyed raise exception' do
        sampler
        SampleModel.first.destroy
        SampleModel.last.destroy
        expect {
          10.times { sampler.loop }
        }.to raise_exception(ActiveRecordSamplooper::Gone)
      end

      it 'sampler not include new instance' do
        sampler
        new_id = create(:sample_model).id
        1000.times { expect(sampler.sample.id).not_to eq(new_id) }
      end

      context 'fixnum parameter get multiple element' do
        it 'pick(n) get multiple element' do
          re = sampler.pick(3)
          expect(re.size).to eq(3)
          re.each do |element|
            expect(element).to be_a(SampleModel)
          end
        end

        it 'loop(n) get multiple element' do
          re = sampler.loop(3)
          expect(re.size).to eq(3)
          re.each do |element|
            expect(element).to be_a(SampleModel)
          end
        end

        it 'sample(n) get multiple element' do
          re = sampler.sample(3)
          expect(re.size).to eq(3)
          re.each do |element|
            expect(element).to be_a(SampleModel)
          end
        end
      end
    end
  end


  describe 'no record' do
    it 'direct sample get nil' do
      expect(SampleModel.sample).to be_nil
    end

    let(:sampler) { SampleModel.sampler }

    it 'sampler sample get nil' do
      expect(sampler.pick).to be_nil
    end

    it 'sampler loop get nil' do
      expect(sampler.pick).to be_nil
    end
  end

  describe 'array samplooper' do
    let(:array) { (:a..:f).to_a }

    describe 'from sampler' do
      let(:sampler) { array.sampler }

      describe 'sampler pick' do
        it 'any times, get SampleModel instance' do
          36.times { expect(sampler.sample).to be_a(Symbol) }
        end
      end

      it 'sample get once each' do
        6.times { expect(sampler.pick).to be_a(Symbol) }
        expect(sampler.pick).to be_nil
      end

      it 'loop get any times each' do
        100.times do
          all = (:a..:f).to_a if all.blank?

          expect(all.delete(sampler.loop)).not_to be_nil
        end
      end

      it 'sample get destroyed raise exception' do
        array[4] = nil
        sampler
        expect {
          7.times { sampler.pick }
        }.to raise_exception(ActiveRecordSamplooper::Gone)
      end

      it 'loop get destroyed raise exception' do
        array[4] = nil
        sampler
        expect {
          7.times { sampler.loop }
        }.to raise_exception(ActiveRecordSamplooper::Gone)
      end

      it 'sampler not include new instance' do
        sampler
        array.push(:aa)
        1000.times { expect(sampler.sample).not_to eq(:aa) }
      end
    end
  end
end
