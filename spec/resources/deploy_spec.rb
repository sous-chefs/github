# frozen_string_literal: true

require 'spec_helper'

describe 'github_deploy' do
  step_into :github_deploy
  platform 'ubuntu', '22.04'

  context 'deploy action' do
    recipe do
      github_deploy 'sous-chefs/test-repo' do
        version 'v1.0.0'
        path '/opt/deployments/test-repo'
        owner 'deploy'
        group 'deploy'
      end
    end

    it { is_expected.to create_directory('/opt/deployments/test-repo/releases') }
    it { is_expected.to create_directory('/opt/deployments/test-repo/shared') }
    it { is_expected.to create_link('/opt/deployments/test-repo/current') }
  end
end
