require File.expand_path("../../../spec_helper", __FILE__)

describe Paperclip::Storage::Ftp do
  let(:attachment) do
    model_instance = double()
    model_instance.stub(:id).and_return(1)
    model_instance.stub(:image_file_name).and_return("foo.jpg")

    Paperclip::Attachment.new(:image, model_instance, {
      :storage => :ftp,
      :path    => "/files/:style/:filename",
      :ftp_servers => [
        {
          :host     => "ftp1.example.com",
          :user     => "user1",
          :password => "password1"
        },
        {
          :host     => "ftp2.example.com",
          :user     => "user2",
          :password => "password2"
        }
      ]
    })
  end

  context "#exists?" do
    it "returns false if original_filename not set" do
      attachment.stub(:original_filename).and_return(nil)
      attachment.exists?.should be_false
    end

    it "returns true if the file exists on the primary server" do
      attachment.primary_ftp_server.should_receive(:file_exists?).with("/files/original/foo.jpg").and_return(true)
      attachment.exists?.should be_true
    end

    it "accepts an optional style_name parameter to build the correct file path" do
      attachment.primary_ftp_server.should_receive(:file_exists?).with("/files/thumb/foo.jpg").and_return(true)
      attachment.exists?(:thumb)
    end
  end

  context "#to_file" do
    it "gets the file from the primary server" do
      attachment.primary_ftp_server.should_receive(:get_file).with("/files/original/foo.jpg").and_return(:foo)
      attachment.to_file.should == :foo
    end

    it "accepts an optional style_name parameter to build the correct file path" do
      attachment.primary_ftp_server.should_receive(:get_file).with("/files/thumb/foo.jpg").and_return(:foo)
      attachment.to_file(:thumb).should == :foo
    end

    it "gets an existing file object from the local write queue, if available" do
      file = double("file")
      file.should_receive(:rewind)
      attachment.instance_variable_set(:@queued_for_write, {:original => file})
      attachment.to_file.should == file
    end
  end

  context "#flush_writes"
  context "#flush_deletes"
  context "#primary_ftp_server"
end
