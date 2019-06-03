# frozen_string_literal: true

test_name "check configuration" do
  step "fail on presence of clamps: settings" do
    fail_test "The `clamps` configuration section is obsolete, please use `scale` instead." if options[:clamps]
  end

  step "fail on presence of scale: logic: setting" do
    fail_test "The 'logic' setting in the 'scale' configuration section is obsolete. Please use 'static_files' and 'dynamic_files' instead." if options[:scale] && options[:scale][:logic] # rubocop:disable Metrics/LineLength
  end
end
