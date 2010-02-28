require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'icalendar_steps' do
  def mock_response_with_1_calendar
    mock('response', :body => <<-EOS)
BEGIN:VCALENDAR
X-PUBLISHED-TTL:PT1H
X-WR-CALNAME:Songkick: Your Events (josephwilk)
VERSION:2.0
CALSCALE:GREGORIAN
PRODID:-//Songkick//iCal 1.0//EN
BEGIN:VEVENT
LOCATION:Roundhouse\, Chalk Farm Road\, NW1 8EH London\, UK
DTEND:20100313
URL:http://www.songkick.com/concerts/2712256-noah-and-the-whale-at-roundhouse?s=k&utm_source=ical&utm_medium=feed&utm_campaign=my_events&utm_content=1
DTSTART:20100312
UID:2712256@songkick.com
DTSTAMP:20100225T135037
SUMMARY:Noah & The Whale at Roundhouse
SEQ:0
END:VEVENT
END:VCALENDAR
EOS
  end

  def mock_response_with_no_calendars
    mock('response', :body => "")
  end

  # describe "an untagged scenario" do
  #   it "should not mix in any calendar related methods" do
  #     world.methods.should_not include('response_calendars')
  #     world.methods.should_not include('response_events')
  #   end
  # end

  # describe "a scenario tagged with @ical" do
  #   before(:each) do
  #     scenario.tag! "@ical"
  #   end
  #
  #   it "should add the methods response_calendars and response_events to world" do
  #     world.methods.should include('response_calendars')
  #     world.methods.should include('response_events')
  #   end

    # Then /^I should be presented with an iCalendar feed containing (\d+) calendars?$/ do |expected_num_calendars|
    the_step "I should be presented with an iCalendar feed containing 1 calendar" do
      describe "when 0 events are in the response body" do
        before(:each) do
          world.stub!(:response).and_return(mock_response_with_no_calendars)
        end

        it "should fail" do
          lambda { run_step }.should raise_error(Spec::Expectations::ExpectationNotMetError)
        end

      end

      describe "when 1 events are in the response body" do
        before(:each) do
          world.stub!(:response).and_return(mock_response_with_1_calendar)
        end

        it "should pass" do
          lambda { run_step }.should_not raise_error
        end
      end
    end
  # end
end