require 'spec_helper'

describe 'Operation API' do
  context 'Empty Operation' do

    module Song00
      class Create < Trailblazer::Operation
      end
    end

    it 'does nothing' do
      result = Song00::Create.({})

      expect(result.success?).to be_truthy
      expect(result.failure?).to be_falsy
      expect(result["model"]).to be_nil
    end
  end

  context 'Building a Model' do
    context 'using Model Macro' do
      class Song0
        class Create < Trailblazer::Operation
          step Model( Song0, :new )
        end
      end

      it 'instantiates the model' do
        result = Song0::Create.({})

        expect(result.success?).to be_truthy
        expect(result.failure?).to be_falsy
        expect(result['model']).to  be_a(Song0)
      end
    end

    context 'using our own method' do
      class Song1
        class Create < Trailblazer::Operation
          step :model!

          def model!(options, **)
            options["model"] = Song1.new
          end
        end
      end

      it 'instantiates the model' do
        result = Song1::Create.({})

        expect(result.success?).to be_truthy
        expect(result.failure?).to be_falsy
        expect(result['model']).to  be_a(Song1)
      end
    end

    context 'ActiveRecord style model finding' do
      class Song01
        class Create < Trailblazer::Operation
          step Model( Song01, :find_by )
        end

        class << self
          def find_by(*)
            Song01.new
          end
        end
      end

      it 'finds the model' do
        result = Song01::Create.({})

        expect(result.success?).to be_truthy
        expect(result.failure?).to be_falsy
        expect(result['model']).to  be_a(Song01)
      end
    end

    context 'ActiveRecord style model finding manually' do
      class Song02
        class Create < Trailblazer::Operation
          success :model!

          def model!(options, params:, **)
            options["model"] = Song02.find_by(params[:id])
          end
        end

        class << self
          def find_by(*)
            Song02.new
          end
        end
      end

      it 'finds the model' do
        result = Song02::Create.({})

        expect(result.success?).to be_truthy
        expect(result.failure?).to be_falsy
        expect(result['model']).to  be_a(Song02)
      end
    end

    context 'Dependency Injection 01' do
      class Song003
        class << self
          def find_by(*)
            true
          end
        end
      end

      module Song03
        class Create < Trailblazer::Operation
          step Model( Song003, :find_by )
        end
      end

      it 'finds the model' do
        instance = Song003.new
        class_double = class_double(Song003).as_stubbed_const
        allow(class_double).to receive(:find_by).and_return(instance)
        result = Song03::Create.({}, "model.class"=>class_double)
        expect(result.success?).to be_truthy
        expect(result.failure?).to be_falsy
        expect(result['model']).to eq(instance)
      end
    end

    context 'Dependency Injection 02' do
      class Song04
        class Create < Trailblazer::Operation
          success :model!

          def model!(options, params:, **)
            options["model"] = options['my.model.class'].find_by(params[:id])
          end
        end
      end

      it 'finds the model' do
        class_double = double('Song Class')
        allow(class_double).to receive(:find_by).and_return(Song04.new)
        result = Song04::Create.({}, "my.model.class" => class_double)

        expect(result.success?).to be_truthy
        expect(result.failure?).to be_falsy
        expect(result['model']).to be_a(Song04)
      end
    end
  end
end