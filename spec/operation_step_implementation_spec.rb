require 'spec_helper'

describe 'Step Implementation' do
  context 'Symbol' do
    module Song00
      class Create < Trailblazer::Operation
        step    :id_present?

        def id_present?(options, params:, **)
          params.has_key?(:id)
        end
      end
    end

    it 'success' do
      result = Song00::Create.({id: false})
      expect(result.success?).to be_truthy
    end

    it 'failure' do
      result = Song00::Create.({})
      expect(result.failure?).to be_truthy
    end
  end

  context 'lambda' do
    module Song01
      class Create < Trailblazer::Operation
        step    ->(options, params:, **){ params.has_key?(:id) }
      end
    end

    it 'success' do
      result = Song01::Create.({id: false})
      expect(result.success?).to be_truthy
    end

    it 'failure' do
      result = Song01::Create.({})
      expect(result.failure?).to be_truthy
    end
  end

  context 'Callable module' do
    class CheckTheId
      extend Uber::Callable

      def self.call(options, params:, **)
        params.has_key?(:id)
      end
    end

    module Song02
      class Create < Trailblazer::Operation
        step CheckTheId
      end
    end

    it 'success' do
      result = Song02::Create.({id: false})
      expect(result.success?).to be_truthy
    end

    it 'failure' do
      result = Song02::Create.({})
      expect(result.failure?).to be_truthy
    end
  end

  context 'Macro API' do
    module Macro
      def self.CheckParam(key: :name)
        step = ->(input, options) { input['params'].has_key?(key) }

        [ step, name: "Checking key: '#{key}'" ]
      end
    end

    module Song02
      class Create < Trailblazer::Operation
        step Macro::CheckParam( key: :id )
      end
    end

    it 'success' do
      result = Song02::Create.({id: false})
      expect(result.success?).to be_truthy
    end

    it 'failure' do
      result = Song02::Create.({})
      expect(result.failure?).to be_truthy
    end
  end
end