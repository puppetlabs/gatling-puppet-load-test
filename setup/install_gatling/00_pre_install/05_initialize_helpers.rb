# frozen_string_literal: true

require File.expand_path("../../../setup/helpers/perf_helper", __dir__)
Beaker::TestCase.class_eval { include PerfHelper }
