require 'spec_helper'

describe 'Operation API' do
  context 'Empty Operation' do

    module Song
      class Create < Trailblazer::Operation
      end
    end

    it 'does nothing' do
      result = Song::Create.({})

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
  end
end