World(Rack::Test::Methods)

Given %r{I am on the home page} do
  visit("/")
end

Given %r{I am on the "([^"]*)" page} do |page|
  visit("/#{page}")
end

# Authorization requires that the CaTissue API is configured with client
# access properties as described in the caRuby Tissue +README.md+ file.
Given %q{I am authorized} do
  username = CaTissue.properties[:user].split('@').first
  page.driver.browser.authorize(username, CaTissue.properties[:password])
end

Given %r{the protocol "([^"]*)" exists} do |title|
  Scat::ProtocolFactory.create_protocol(title).find(:create)
end

When %r{I fill in "([^"]*)" with "([^"]*)"} do |field, text|
  fill_in field.underscore.gsub(' ', '_'), :with => text
end

When %r{I click "([^"]*)"} do |button|
  click_on button
end

Then %r{^I should see "([^"]*)"$} do |text|
  page.should have_content text
end

Then %r{I should see the "([^"]*)" field} do |field|
  find_field(field.underscore.gsub(' ', '_')).visible?.should be true
end

Then %q{the matching values are displayed} do
  
end

Then %q{the edit is saved} do
  spc = CaTissue::TissueSpecimen.new(:identifier => page.text.to_i)
  spc.find
  spc.should_not be nil
end
