require 'rubygems'
require 'cucumber'

module Cucumber
  module Stepdefs
    module Macros
      attr_writer :step_name

      def the_step(step_name, &block)
        example_group = block.call
        example_group.step_name = step_name
        example_group
      end

      def step_name
        (@step_name || self.superclass.step_name) rescue raise("step name not defined")
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
        file_to_test = File.expand_path(File.dirname(__FILE__) + '/../lib/cucumber/stepdefs/icalendar.rb')
        step_mother.load_code_file(file_to_test)
        step_mother
      end

      def step_name
        self.class.step_name
      end
    end
  end
end

module Cucumber
  module Stepdefs
    class ExampleGroup < Spec::Example::ExampleGroup
      extend Cucumber::Stepdefs::Macros
      include Cucumber::Stepdefs::WorldHelper
    end
  end
end

Spec::Example::ExampleGroupFactory.default(Cucumber::Stepdefs::ExampleGroup)