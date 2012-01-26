require 'spec_helper'

describe Outline do
  let(:config) do
    Outline.new(:data => { :testing => 'testing' }) do
      foo "foo"
      self.timestamp_format = "%Y%m%d%H%M%S"
      
      web do
        server "my-proj.com"
        branch "master"
        remote "origin"
      end
      
      commands do
        ssh "ssh deployer@#{parent.web.server}"
      end
      
      toggle
      some.deep.indented.config 'foo'
    end
  end
  
  describe "getters" do
    it "should work" do
      config.testing.should == "testing"
      config.foo.should == "foo"
      proc { config.foo = "bar" }.call.should == "bar"
      config.timestamp_format.should == "%Y%m%d%H%M%S"
      config.some.deep.indented.config.should == 'foo'
    end
  end
  
  describe "#web" do
    subject { config.web }
    it { should be_a(Outline) }
    
    it "should return the correct values" do
      subject.server.should == "my-proj.com"
      subject.branch.should == "master"
      subject.remote.should == "origin"
    end
  end
  
  describe "#commands" do
    subject { config.commands }
    it { should be_a(Outline) }
    
    describe "#ssh" do
      subject { config.commands.ssh }
      it { should == "ssh deployer@my-proj.com" }
    end
  end
  
  describe "#data" do
    it "should be able to be manipulated from outside of the Outline" do
      config.data[:from_outside] = "Hello"
      config.from_outside.should == "Hello"
      config.from_outside = "Goodbye"
      config.data[:from_outside].should == "Goodbye"
    end
  end
  
  describe "#to_h" do
    # it "should return the correct Hash output" do
    #   config.to_h.should == {
    #     :testing => 'testing',
    #     :foo => 'foo',
    #     :timestamp_format => "%Y%m%d%H%M%S",
    #     :web => {
    #       :server => "my-proj.com",
    #       :branch => "master",
    #       :remote => "origin"
    #     },
    #     :commands => {
    #       :ssh => "ssh deployer@my-proj.com"
    #     },
    #     :some => {
    #       :deep => {
    #         :indented => {
    #           :config => 'foo'
    #         }
    #       }
    #     }
    #   }
    # end
  end
  
end