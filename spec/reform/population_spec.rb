require 'spec_helper'
require 'reform/form/dry'

RSpec.describe 'Full Name' do
  Data = Struct.new(:full_name)

  class FullNameForm < Reform::Form
    feature Reform::Form::Dry

    FullNamePopulator = ->(options) do
      options[:represented].model.full_name = "#{options[:doc]['first_name']} #{options[:doc]['last_name']}"
      options[:represented].first_name = options[:doc]['first_name']
      options[:represented].last_name = options[:doc]['last_name']
      puts "Populator called"
    end

    property :first_name, populator: FullNamePopulator, virtual: true
    property :last_name, populator: FullNamePopulator, virtual: true

    validation :default do
      required(:first_name).filled
      required(:last_name).filled
    end
  end

  specify 'Positive case' do
    input = {first_name: 'John', last_name: 'Smith'}
    form = FullNameForm.new(Data.new)
    form.validate(input)
    expect(form.valid?).to be_truthy
    expect(form.model.full_name).to eq("#{input[:first_name]} #{input[:last_name]}")
  end
end
