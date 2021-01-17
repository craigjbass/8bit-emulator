require 'processor'
require 'digirule'

def repeat_for_both_implementations(&block)
  [ 
    [ 'emulator', Proc.new do
        Processor.new
      end
    ], 
    [ 'digirule', Proc.new do
        digirule = Digirule.new 
        digirule.connect(ENV['SERIAL_PORT'])
        digirule
      end
    ]
  ].each do |name, factory|
    context name do
      let(:processor) { factory.call }

      instance_eval(&block)
    end
  end
end

