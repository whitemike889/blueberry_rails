require 'rails_helper'

FactoryBot.factories.map(&:name).each do |factory_name|
  RSpec.describe "factory #{factory_name}" do
    it 'is valid' do
      factory = build(factory_name)

      if factory.respond_to?(:valid?)
        expect(factory).to be_valid, factory.errors.full_messages.join(',')
      end
    end
  end
end
