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
      attr_writer :tags

      def the_step(step_name, &block)
        example_group = describe(step_name, &block)
        example_group.step_name = step_name
        example_group
      end

      def with_tag(tag, &block)
        with_tags([tag], &block)
      end

      def without_tags(&block)
        describe("an untagged scenario", &block)
      end

      def with_tags(tags, &block)
        example_group = describe("Scenarios tagged with #{tags.inspect}", &block)
        example_group.tags ||= []
        example_group.tags = tags
        example_group
      end

      def step_name
        return @step_name if @step_name
        return self.superclass.step_name if self.superclass.respond_to?(:step_name)
        raise("Step name not defined")
      end

      def tags
        if self.superclass.respond_to?(:tags)
          return @tags.nil? ? self.superclass.tags : @tags + self.superclass.tags
        else
          return []
        end
      end

      def step_file
        File.expand_path(File.dirname(__FILE__) + '/../lib/cucumber/stepdefs/icalendar_steps.rb')
      end

      def it_should_pass
        it "should pass" do
          lambda { run_step }.should_not raise_error
        end
      end

      def it_should_fail_with(exception)
        it "should fail" do
          lambda { run_step }.should raise_error(exception)
        end
      end

    end

    module WorldHelper
      class FakeScenario
        def initialize(tags)
          @tags = tags
        end

        def accept_hook?(hook)
          hook.tag_expressions.any?{|tag| @tags.include?(tag)}
         end

        def language
          'en'
        end
      end

      def scenario
        @scenario ||= FakeScenario.new(self.class.tags)
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
        step_file = self.class.step_file
        @step_mother.load_code_file(step_file)
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