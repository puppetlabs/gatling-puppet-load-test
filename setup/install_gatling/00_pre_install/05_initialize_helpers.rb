require File.expand_path('../../../../setup/helpers/perf_helper', __FILE__)
Beaker::TestCase.class_eval { include PerfHelper }
