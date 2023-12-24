# frozen_string_literal: true

RSpec.describe Interactify do
  it 'has a version number' do
    expect(Interactify::VERSION).not_to be nil
  end

  describe '.each' do
    module self::SomeNamespace
      A = Class.new do
        include Interactor
        before { context.a ||= [] }

        def call
          context.a.push(context.thing * 1)
        end
      end

      B = Class.new do
        include Interactor
        before { context.b ||= [] }

        def call
          context.b.push(context.thing * 2)
        end
      end

      C = Class.new do
        include Interactor
        before { context.c ||= [] }

        def call
          context.c.push(context.thing * 3)
        end
      end
    end

    def k(klass)
      self.class::SomeNamespace.const_get(klass)
    end

    it 'creates an interactor class that iterates over the given collection' do
      allow(SpecSupport).to receive(:const_set).and_wrap_original do |meth, name, klass|
        expect(name).to eq(:EachThing)
        expect(klass).to be_a(Class)
        expect(klass.ancestors).to include(Interactor)
        meth.call(name, klass)
      end

      klass = SpecSupport.each(:things, k(:A), k(:B), k(:C))
      expect(klass.name).to eq('SpecSupport::EachThing')

      file, line = klass.source_location
      expect(file).to match %r{spec/support/spec_support_binding\.rb}
      expect(line).to eq(1)

      result = klass.call!(:things => [1, 2, 3])
      expect(result.a).to eq([1, 2, 3])
      expect(result.b).to eq([2, 4, 6])
      expect(result.c).to eq([3, 6, 9])
    end
  end
end
