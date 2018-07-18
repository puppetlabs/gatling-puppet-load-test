require 'rspec'
require File.expand_path('../../../../tests/helpers/perf_run_helper', __FILE__)
require 'minitest/assertions'

class PerfRunHelperClass
  include PerfRunHelper
  include Minitest::Assertions

end

describe PerfRunHelperClass do

  describe '.assert_later' do

    context 'when true' do
      it 'does not raise, or store exception' do
        expect(subject).to receive(:assertion_exceptions).and_return([])
        expect(subject).to receive(:assert).with(true == true, 'expression = true')
        subject.assert_later(true == true, 'expression = true')
        expect(subject.assertion_exceptions.length).to eq(0)
      end
    end

    context 'when false' do
      it 'does not raise, but does store exception' do
        expect(subject).to receive(:assert).with(true == false, 'expression = false')
          .and_raise(Minitest::Assertion, 'expression = false')
        allow(subject).to receive(:assertion_exceptions).and_call_original
        subject.assert_later(true == false, 'expression = false')
        expect(subject.assertion_exceptions.length).to eq(1)
      end
    end

  end

  describe '.assert_all' do
    let(:logger) { double }
    before { allow( subject ).to receive( :logger ).and_return( logger ) }

    context 'when assertion fails' do
      it 'raises exception' do
        allow(subject).to receive(:assertion_exceptions).and_call_original

        expect(subject).to receive(:flunk).with('One or more assertions failed')
          .and_raise(Minitest::Assertion, 'One or more assertions failed')
        expect(logger).to receive(:error).with(/expression = false/)

        subject.assertion_exceptions.push(Minitest::Assertion.new('expression = false'))
        expect { subject.assert_all }.to raise_error(Minitest::Assertion, 'One or more assertions failed')
      end
    end

    context 'when no assertions fail' do
      it 'does not raise exception' do
        allow(subject).to receive(:assertion_exceptions).and_call_original
        allow(subject).to receive(:assert).with(true == true, 'expression = true')

        subject.assert_later(true == true, 'expression = true')
        subject.assert_later(true == true, 'expression = true')

        expect { subject.assert_all }.not_to raise_error
      end
    end

    context 'when more than one assertion fails' do
      it 'raises a single exception' do
        allow(subject).to receive(:assertion_exceptions).and_call_original

        expect(subject).to receive(:flunk).with('One or more assertions failed')
          .and_raise(Minitest::Assertion, 'One or more assertions failed')
        subject.assertion_exceptions.push(Minitest::Assertion.new('expression = false 1'))
        subject.assertion_exceptions.push(Minitest::Assertion.new('expression = false 2'))
        expect(logger).to receive(:error).with(/expression = false 1/)
        expect(logger).to receive(:error).with(/expression = false 2/)

        expect { subject.assert_all }.to raise_error(Minitest::Assertion, 'One or more assertions failed')
      end
    end

  end

end
