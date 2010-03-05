require 'icalendar'

module Cucumber
  module Stepdefs
    module Icalendar
      def response_calendars
        ::Icalendar.parse(response.body)
      end

      def response_events
        response_calendars.length.should == 1
        response_calendars.first.events
      end
    end
  end
end

Before('@ical') do
  extend Cucumber::Stepdefs::Icalendar
end

Then /^I should be presented with an iCalendar feed containing (\d+) calendars?$/ do |expected_num_calendars|
  response_calendars.length.should == expected_num_calendars.to_i
end

Then /^the iCalendar should have exactly (\d+) events?$/ do |number_of_events|
  response_events.length.should == number_of_events.to_i
end

Then /^all the events in my calendar should be all day events$/ do
  response_events.each do |event|
    event.dtend.should == event.dtstart + 1.day
  end
end

Then /^I should not see any events in my calendar feed$/ do
  response_events.length.should == 0
end

Then /^the iCalendar should have a multi\-day event lasting (\d+) days$/ do |num_days|
  response_events.any? { |event| event.dtend == event.dtstart + num_days.to_i.days }.should be_true
end

Spec::Matchers.define :have_an_event_with do |options|
  match do |events|
    events.any? do |event|
      matches_options? options, event
    end
  end

  def matches_options?(options, event)
    options.each do |key, value|
      return false unless event.send(key) == value
    end
    true
  end

  failure_message_for_should do |events|
    "Expected to find an event with '#{options.inspect}' in the following events: #{events.inspect}"
  end
end

Then /^the iCalendar should have an event with the title "([^\"]*)"$/ do |event_title|
  response_events.should have_an_event_with(:summary => event_title)
end

Then /^the iCalendar should have an event with the location "([^\"]*)"$/ do |expected_location|
  response_events.should have_an_event_with(:location => expected_location)
end

Then /^the iCalendar should have the following properties:$/ do |properties|
  properties.hashes.each do |property_row|
    response.body.should =~ /^#{property_row[:name]}.*#{property_row[:value]}/
  end
end

Then /^the iCalendar should have an event with the text "([^\"]*)" in the description$/ do |text|
  response_events.any? do |event|
    event.description.should =~ /#{text}/
  end.should be_true
end
