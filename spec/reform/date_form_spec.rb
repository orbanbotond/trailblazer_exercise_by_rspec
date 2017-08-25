require 'spec_helper'
require 'reform/form/dry'
require 'reform/form/coercion'

class DateForm < Reform::Form
  feature Reform::Form::Dry
  feature Coercion

  property :start_date, type: Types::Form::Date

  validation :default do
    required(:start_date).filled
  end
end

describe DateForm do
  let(:params) { {start_date: '2017-08-12'} }

  context 'Negative Cases' do
    BookingExportInterval = Struct.new(:start_date, :end_date)

    specify 'start_date is missing' do
      input = {}
      form = DateForm.new(BookingExportInterval.new)
      form.validate(input)
      expect(form.valid?).to be_falsy
      expect(form.errors[:start_date]).to be
    end
  end

  context 'positive case' do
    specify 'all the data is serialized and populated'do
      form = DateForm.new(BookingExportInterval.new)
      form.validate(params)
      expect(form.valid?).to be_truthy
      form.sync
      expect(form.model).to be
      expect(form.model.start_date).to be
      expect(form.model.start_date).to be_a(Date)
    end
  end
end
