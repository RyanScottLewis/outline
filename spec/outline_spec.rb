require 'outline'

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
      
      multiple 'foo', 'bar', 'baz'
      
      commands say_hello: "echo 'Why, hello there'" do
        ssh "ssh deployer@#{parent.web.server}"
        
        deploy Proc.new { "deploy completed" }
        command :foo do
          bar 'bar'
        end
        
        wget opts: '-a -b -c'
      end
      
      some.deep.indented.config 'foo'
    end
  end
  
  describe 'VERSION' do
    it "should be correct" do
      Outline::VERSION.should == '0.2.0'
    end
  end
  
  describe "getters" do
    it "should work" do
      config.testing.should == "testing"
      config.foo.should == "foo"
      proc { config.foo = "bar" }.call.should == "bar"
      config.timestamp_format.should == "%Y%m%d%H%M%S"
      config.multiple.should == ['foo', 'bar', 'baz']
      config.some.deep.indented.config.should == 'foo'
    end
    
    it 'should contain the correct methods' do
      config.instance_eval { @methods }.should == [:foo, :timestamp_format, :web, :multiple, :commands, :some]
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
    
    it "should return the correct values" do
      config.commands.say_hello.should == "echo 'Why, hello there'"
      config.commands.ssh.should == "ssh deployer@my-proj.com"
      config.commands.deploy.class.should == Proc
      config.commands.deploy.call.should == "deploy completed"
      config.commands.command.value.should == :foo
      config.commands.command.bar.should == 'bar'
      config.commands.wget.opts.should == '-a -b -c'
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
    it "should return the correct Hash output" do
      config.to_h[:testing].should == "testing"
      config.to_h[:foo].should == "foo"
      config.to_h[:timestamp_format].should == "%Y%m%d%H%M%S"
      config.to_h[:web].should == { server: "my-proj.com", branch: "master", remote: "origin" }
      config.to_h[:multiple].should == ["foo", "bar", "baz"]
      config.to_h[:commands].should be_a(Hash)
      config.to_h[:commands][:say_hello].should == "echo 'Why, hello there'"
      config.to_h[:commands][:ssh].should == "ssh deployer@my-proj.com"
      config.to_h[:commands][:deploy].should be_a(Proc)
      config.to_h[:commands][:command].should == { value: :foo, bar: "bar" }
      config.to_h[:commands][:wget].should == { opts: "-a -b -c" }
      config.to_h[:some][:deep][:indented][:config].should == "foo"
    end
  end
  
end

describe "Hash conversion" do
  it "properly convert into a Hash" do
    outline = { a: 'a', b: 'b', some: { deep: { indented: { config: 'foo' } } } }.to_outline
    
    outline.a.should == 'a'
    outline.b.should == 'b'
    outline.some.deep.indented.config.should == 'foo'
  end
end