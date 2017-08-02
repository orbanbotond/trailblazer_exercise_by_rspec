require 'spec_helper'

describe 'Flow Control' do
  context 'Two failure tracker' do
    module Song00
      class Create < Trailblazer::Operation
        step    :model!
        failure :error!
        step    :populate!
        failure :error_in_populate!

        def model!(options, params:, **)
          params[:how_is_the_model]
        end

        def populate!(options, params:, **)
          params[:how_is_the_model_2]
        end

        def error!(options, params:, **)
          options["result.error"] = true
        end

        def error_in_populate!(options, params:, **)
          options["result.error_in_populate"] = true
        end
      end
    end

    it 'success' do
      result = Song00::Create.({how_is_the_model: true, how_is_the_model_2: true})

      expect(result.success?).to be_truthy
    end

    it 'failure 1' do
      result = Song00::Create.({how_is_the_model: false})

      expect(result.success?).to be_falsy
      expect(result.failure?).to be_truthy
      expect(result["result.error_in_populate"]).to be_truthy
      expect(result["result.error"]).to be_truthy
    end

    it 'failure 2' do
      result = Song00::Create.({how_is_the_model: true, how_is_the_model_2: false})

      expect(result.success?).to be_falsy
      expect(result.failure?).to be_truthy
      expect(result["result.error"]).to be_falsy
      expect(result["result.error_in_populate"]).to be_truthy
    end
  end

  context 'Two failure tracker with fail_fast' do
    module Song01
      class Create < Trailblazer::Operation
        step    :model!
        failure :abort!,  fail_fast: true
        step    :populate!
        failure :error_in_populate!

        def model!(options, params:, **)
          params[:how_is_the_model]
        end

        def populate!(options, params:, **)
          params[:how_is_the_model_2]
        end

        def abort!(options, params:, **)
          options["result.error"] = true
        end

        def error_in_populate!(options, params:, **)
          options["result.error_in_populate"] = true
        end
      end
    end

    it 'failure 1' do
      result = Song01::Create.({how_is_the_model: false})

      expect(result.failure?).to be_truthy
      expect(result["result.error"]).to be_truthy
      expect(result["result.error_in_populate"]).to be_nil
    end

    it 'failure 2' do
      result = Song01::Create.({how_is_the_model: true, how_is_the_model_2: false})

      expect(result.success?).to be_falsy
      expect(result.failure?).to be_truthy
      expect(result["result.error"]).to be_falsy
      expect(result["result.error_in_populate"]).to be_truthy
    end
  end

  context 'Fail_fast in the step' do
    module Song02
      class Create < Trailblazer::Operation
        step    :id_present?, fail_fast: true
        failure :abort!
        step    :populate!
        failure :error_in_populate!

        def id_present?(options, params:, **)
          params.has_key? :id
        end

        def populate!(options, params:, **)
          options['result.how_is_the_model'] = true
        end

        def abort!(options, params:, **)
          options["result.error"] = true
        end

        def error_in_populate!(options, params:, **)
          options["result.error_in_populate"] = true
        end
      end
    end

    it 'id is there' do
      result = Song02::Create.({id: nil})

      expect(result.success?).to be_truthy
      expect(result["result.how_is_the_model"]).to be_truthy
    end

    it 'id is missing' do
      result = Song02::Create.({})

      expect(result.success?).to be_falsy
      expect(result["result.error"]).to be_nil
      expect(result["result.how_is_the_model"]).to be_nil
    end
  end

  context 'Emiting fail fasts manually' do
    module Song03
      class Create < Trailblazer::Operation
        step :filter_params!
        step :record!
        failure :handle_fail!

        def filter_params!(options, params:, **)
          unless params.has_key?(:id)
            options["result.params"] = "No ID in params!"
            return Railway.fail_fast!
          end
          true
        end

        def handle_fail!(options, **)
          options["my.status"] = "Broken!"
        end

        def record!(options, **)
          options["record"] = "There!"
        end
      end
    end

    it 'id is there' do
      result = Song03::Create.({id: nil})

      expect(result.success?).to be_truthy
      expect(result["record"]).to eq('There!')
      expect(result["result.params"]).to be_nil
      expect(result["my.status"]).to be_nil
    end

    it 'id is missing' do
      result = Song03::Create.({})

      expect(result.success?).to be_falsy
      expect(result["my.status"]).to be_nil
      expect(result["result.params"]).to eq('No ID in params!')
    end
  end
end