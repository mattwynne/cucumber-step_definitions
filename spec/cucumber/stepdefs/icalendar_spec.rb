require 'rubygems'
require 'cucumber'

module Cucumber
  module Stepdefs
    module Macros
      attr_accessor :step_name
      
      def the_step(step_name, &block)
        # TODO: figure out how to make this work for nested describes - it will only work one deep at the moment
        example_group = block.call
        example_group.step_name = step_name
        example_group
      end
    end
    
    module WorldHelper
      
      def scenario
        result = mock('scenario', :language => 'en')
        result.stub!(:accept_hook?) do |hook|
          if hook.tag_expressions.include? '@ical'
            true 
          else
            false
          end
        end
        result
      end
      
      def world
        rb = step_mother.load_programming_language('rb')
        rb.before(scenario)
        rb.current_world
      end
      
      def run_step
        step_mother.invoke(step_name)
      end
      
      private
      
      def step_mother
        return @step_mother if @step_mother
        @step_mother = ::Cucumber::StepMother.new
        file_to_test = File.expand_path(File.dirname(__FILE__) + '/../../../lib/cucumber/stepdefs/icalendar.rb')
        step_mother.load_code_file(file_to_test)
        step_mother
      end
      
      def step_name
        self.class.step_name or raise("step name not defined")
      end
    end
  end
end

describe 'icalendar_steps' do
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
    URL:http://www.songkick.com/concerts/2712256-noah-and-the-whale-at-roundhou
     se?s=k&utm_source=ical&utm_medium=feed&utm_campaign=my_events&utm_content=1
     04081
    DTSTART:20100312
    UID:2712256@songkick.com
    DTSTAMP:20100225T135037
    DESCRIPTION:You might go\n\nhttp://www.songkick.com/concerts/2712256-noah-a
     nd-the-whale-at-roundhouse?s=k&utm_source=ical&utm_medium=feed&utm_campaign
     =my_events&utm_content=104081
    SUMMARY:Noah & The Whale at Roundhouse
    SEQ:0
    END:VEVENT
    END:VCALENDAR
EOS
  end

  def mock_response_with_no_events
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
  
  extend Cucumber::Stepdefs::Macros
  include Cucumber::Stepdefs::WorldHelper
  
  
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
          world.stub!(:response).and_return(mock_response_with_no_events)
        end
      
        it "should fail" do
          lambda { run_step }.should raise_error(Spec::Expectations::ExpectationNotMetError)
        end
      end
      # describe "when 1 events are in the response body" do
      #   before(:each) do
      #     world.stub!(:response).and_return(mock_response_with_1_event)
      #   end
      #     
      #   it "should pass" do
      #     lambda { run_step }.should_not raise_error
      #   end
      # end
    end
  # end
end