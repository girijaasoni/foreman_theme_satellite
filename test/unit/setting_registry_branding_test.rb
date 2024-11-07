require 'test_plugin_helper'

class SettingRegistryBrandingTest < ActiveSupport::TestCase
  # rubocop:disable Metrics/BlockLength
  describe 'stubbed creation' do
    test 'it replaces value to a branded one using DSL' do
      Setting.where(name: 'dsl_setting').delete_all
      branded_settings = Foreman.settings.branded_settings.deep_dup
      branded_settings['dsl_setting'] = 'TEST_VALUE'
      Foreman.settings.stubs(:branded_settings).returns(branded_settings)

      Foreman::SettingManager.define('TEST_ID') do
        category(:General) do
          setting(
            :dsl_setting,
            description: N_("Testing settings DSL for branding"),
            default: '[foreman]',
            full_name: N_('DSL test setting'),
            type: :string
          )
        end
      end

      Foreman.settings.load

      # Assert that the value is properly branded despite the definition.
      assert_equal 'TEST_VALUE', Setting['dsl_setting']
    end

    test 'hides upstream-only settings' do
      Foreman::SettingManager.define('test2') do
        category(:Content) do
          setting(
            :test_setting,
            description: N_("Upstream-only setting test"),
            default: 'definitely not falsey',
            full_name: N_('Upstream-only setting test'),
            type: :string
          )
        end
      end
      Foreman.settings.load
      UpstreamOnlySettings.expects(:include?).with('test_setting').returns(true)
      assert_nil Setting['test_setting']
    end
  end
  # rubocop:enable Metrics/BlockLength
end

class SettingBrandingTest < ActiveSupport::TestCase
  test 'replaces warning for upstream-only settings' do
    UpstreamOnlySettings.expects(:include?).with('test_setting').returns(true)
    Rails.logger.expects(:debug).with('Setting \'test_setting\' is not available in Satellite; ignoring')
    Setting['test_setting']
  end
end