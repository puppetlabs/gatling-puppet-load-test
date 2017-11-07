test_name 'check configuration' do
  step 'fail on presence of clamps: settings' do
    if options[:clamps]
      fail_test "The `clamps` configuration section is obsolete, please use `scale` instead."
    end
  end

  step 'fail on presence of scale: logic: setting' do
    if options[:scale] && options[:scale][:logic]
      fail_test "The 'logic' setting in the 'scale' configuration section is obsolete. Please use 'static_files' and 'dynamic_files' instead."
    end
  end
end
