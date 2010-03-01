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
END:VCALENDAR
EOS
  end

  def mock_response_with_1_event
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

  def world_methods
    (world.methods - Object.methods)
  end

  describe "an untagged scenario" do
    it "should not mix in any calendar related methods" do
      world_methods.should_not include('response_calendars')
      world_methods.should_not include('response_events')
    end
  end

  with_tag '@ical' do
    ['response_calendars', 'response_events'].each do |method|
      it "should add the #{method} to world" do
        world_methods.should include(method)
      end
    end

    # Then /^the iCalendar should have exactly (\d+) events?$/
    the_step "the iCalendar should have exactly 1 event" do
      describe "when 1 calendar with 0 event is in the response body" do
        before(:each) do
          world.stub!(:response).and_return(mock_response_with_1_calendar)
        end

        it_should_fail_with(Spec::Expectations::ExpectationNotMetError)

      end

      describe "when 1 calendar with 1 event is in the response body" do
        before(:each) do
          world.stub!(:response).and_return(mock_response_with_1_event)
        end

        it_should_pass

      end
    end

    # Then /^I should be presented with an iCalendar feed containing (\d+) calendars?$/
    the_step "I should be presented with an iCalendar feed containing 1 calendar" do
      describe "when 0 calendars are in the response body" do
        before(:each) do
          world.stub!(:response).and_return(mock_response_with_no_calendars)
        end

        it_should_fail_with(Spec::Expectations::ExpectationNotMetError)

      end

      describe "when 1 calendar is in the response body" do
        before(:each) do
          world.stub!(:response).and_return(mock_response_with_1_calendar)
        end

        it_should_pass
      end
    end
  end
end