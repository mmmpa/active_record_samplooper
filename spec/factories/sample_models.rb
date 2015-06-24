FactoryGirl.define do
  factory :sample_model do
    name { SecureRandom.hex(4) }
  end
end
