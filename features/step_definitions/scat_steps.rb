World(Rack::Test::Methods)

Given %r{I am on the (\w+) page} do |page|
  visit("/#{page unless page =~ /^([Hh]ome|[Ee]dit)$/}")
end

# Authorization requires that the CaTissue API is configured with client
# access properties as described in the caRuby Tissue +README.md+ file.
Given %q{I am authorized} do
  username = CaTissue.properties[:user].split('@').first
  page.driver.browser.authorize(username, CaTissue.properties[:password])
end

Given %r{the protocol "([^"]*)" exists} do |title|
  Scat::Seed.protocol_for(title).find(:create)
end

When %r{I fill in(?: the)? "([^"]*)"(?: field)? with "([^"]*)"} do |name, text|
  fill_in Scat::Edit.instance.input_id(name), :with => text
end

When %r{I check(?: the)? "([^"]*)(?: checkbox)?"} do |name|
  check Scat::Edit.instance.input_id(name)
end

When %r{I click "([^"]*)"} do |name|
  click_on name
end

Then %r{I should see the "([^"]*)" field} do |name|
  find_field(Scat::Edit.instance.input_id(name)).visible?.should be true
end

Then %q{the status should show the label} do
  find(:status).text.should match /label \d+\.$/
end

Then %q{the specimen should be saved} do
  lbl = /label (\d+)\.$/.match(find(:status).text).captures.first
  lbl.should_not be nil
  CaTissue::Specimen.new(:label => lbl).find.should_not be nil
end

Then %r{^I should see "([^"]*)"$} do |text|
  page.should have_content text
end

After do |scenario|
  save_and_open_page if scenario.failed?
end
