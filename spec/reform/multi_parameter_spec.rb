# require 'spec_helper'
# require 'reform/form/dry'
# require 'reform/form/coercion'

# class DateForm < Reform::Form
#   feature Reform::Form::Dry
#   feature Reform::Form::MultiParameterAttributes

#   property :start_date, :multi_params => true

#   validation :default do
#     required(:start_date).filled
#   end
# end

# describe DateForm do
#   let(:params) { {'start_date(1i)' => '2017',
#                   'start_date(2i)' => '08',
#                   'start_date(3i)' => '12' } }

#   context 'Negative Cases' do
#     BookingExportInterval = Struct.new(:start_date, :end_date)

#     context 'missing' do
#       specify 'entirely' do
#         input = {}
#         form = DateForm.new(BookingExportInterval.new)
#         form.validate(input)
#         expect(form.valid?).to be_falsy
#         expect(form.errors[:start_date]).to be
#       end

#       specify 'partially' do
#         input = params.except('start_date(1i)')
#         form = DateForm.new(BookingExportInterval.new)
#         form.validate(input)
#         expect(form.valid?).to be_falsy
#         expect(form.errors[:start_date]).to be
#       end
#     end
#   end

#   context 'positive case' do
#     specify 'all the data is serialized and populated'do
#       form = DateForm.new(BookingExportInterval.new)
#       form.validate(params)
#       expect(form.valid?).to be_truthy
#       form.sync
#       expect(form.model).to be
#       expect(form.model.start_date).to be
#       expect(form.model.start_date).to be_a(Date)
#     end
#   end
# end
