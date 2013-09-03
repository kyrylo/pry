require 'helper'

module BeforeHookAbility
  def before_each_method(*args)
    instance_methods.each { |name|
      m = instance_method(name)

      define_method(name) do |*args, &block|
        instance_exec(&Proc.new)
        m.bind(self).call(*args, &block)
      end
    }
  end
end

class ShowTreeTester
  extend BeforeHookAbility

  attr_reader :destroyed
  alias_method :destroyed?, :destroyed

  def initialize(sym, klass)
    @class_name = sym
    @destroyed = false
    Object.const_set(sym, Class.new)
  end

  def const_set(sym, val)
    test_class.const_set(sym, val)
  end

  def remove_const(sym)
    test_class.remove_const(sym)
  end

  def destroy!
    Object.remove_const(@class_name)
    @destroyed = true
  end

  def test_class
    Object.const_get(@class_name)
  end

  def with_defined_const(sym, val)
    test_class.tap do |tree_klass|
      tree_klass.const_set(sym, val)
      yield
      tree_klass.remove_const(sym)
    end
  end

  before_each_method { puts 'aa' }
end

describe 'show-tree' do

  before do
    @tester = ShowTreeTester.new(:ShowTreeTest, Class.new)
    @tester.const_set(:Funky, Class.new)
  end

  after do
    @tester.remove_const(:Funky)
    Object.remove_const(:ShowTreeTest)
  end

  describe "in the current context" do
    before do
      @show_tree = ->{ pry_eval(ShowTreeTest, 'show-tree') }
    end

    it "displays constants" do
      @tester.with_defined_const(:WILLY, :constant) do
        @show_tree.call.should =~ /\s{2}WILLY/
      end
    end

    it "displays classes" do
      @tester.with_defined_const(:Billy, Class.new) do
        @show_tree.call.should =~ /\s{2}\-Billy\-/
      end
    end

    it "displays modules" do
      @tester.with_defined_const(:Dilly, Module.new) do
        @show_tree.call.should =~ /\s{2}=Dilly=/
      end
    end

    it "displays ivars" do
      binding.pry
    end

    it "displays class vars" do
    end

    describe "methods view" do
      it "displays public methods" do
      end

      it "displays private methods" do
      end

      it "displays protected methods" do
      end

      it "displays aliases" do
      end
    end
  end

end
