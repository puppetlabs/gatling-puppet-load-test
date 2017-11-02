require 'classification_helper'

test_name 'Update NC Class cache' do
  step 'update_classes' do
    update_classifier_classes
  end
end
