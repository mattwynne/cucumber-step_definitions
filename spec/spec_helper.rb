require 'rubygems'
require 'cucumber'
require 'cucumber/rb_support/rb_language'

module Cucumber
  module RbSupport
    class RbLanguage
      # HACK: Patch Cucumber replacing require so we always load the step  definitions
      # TODO: Move step mother outside of example group context
      def load_code_file(code_file)
        load File.expand_path(code_file)
      end
    end
  end
end

module Cucumber
  module Stepdefs
    module Macros
      attr_writer :step_name

      def the_step(step_name, &block)
        example_group = describe(step_name, &block)
        example_group.step_name = step_name
        example_group
      end

      def step_name
        return @step_name if @step_name
        return self.superclass.step_name if self.superclass.respond_to?(:step_name)
        raise("step name not defined")
      end
      
      def step_file
        File.expand_path(File.dirname(__FILE__) + '/../lib/cucumber/stepdefs/icalendar_steps.rb')
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
        @step_mother.load_code_file(self.class.step_file)
        @step_mother
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