require 'spec_helper'

feature 'Outdated browsers support:' do
  context 'when the user browser is outdated' do
    before(:each) do
      ie_10_user_agent = 'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)'
      Capybara.page.driver.header('user-agent', ie_10_user_agent)
    end

    scenario 'a banner is displayed' do
      visit new_user_session_path
      expect(page).to have_content('Internet Explorer 10 est trop ancien')
    end

    scenario 'the banner can be dismissed' do
      visit new_user_session_path
      expect(page).to have_content('Internet Explorer 10 est trop ancien')

      # The banner is hidden immediately
      within '#outdated-browser-banner' do
        click_on 'Ignorer'
      end
      expect(page).not_to have_content('Internet Explorer 10 est trop ancien')
      expect(page).to have_current_path(new_user_session_path)

      # The banner is hidden after a refresh
      page.refresh
      expect(page).not_to have_content('Internet Explorer 10 est trop ancien')
    end
  end
end
