require File.expand_path("../../../../spec_helper", __FILE__)

describe Paperclip::Storage::Ftp::Server do
  let(:server) { Paperclip::Storage::Ftp::Server.new }

  context "initialize" do
    it "accepts options to initialize attributes" do
      options = {
        :host     => "ftp.example.com",
        :user     => "user",
        :password => "password"
      }
      server = Paperclip::Storage::Ftp::Server.new(options)
      server.host.should     == "ftp.example.com"
      server.user.should     == "user"
      server.password.should == "password"
    end
  end

  context "#file_exists?" do
    it "returns true if the file exists on the server" do
      server.connection = double("connection")
      server.connection.should_receive(:nlst).with("/files/original").and_return(["foo.jpg"])
      server.file_exists?("/files/original/foo.jpg").should be_true
    end

    it "returns false if the file does not exist on the server" do
      server.connection = double("connection")
      server.connection.should_receive(:nlst).with("/files/original").and_return([])
      server.file_exists?("/files/original/foo.jpg").should be_false
    end
  end

  context "#get_file"
  context "#connection"
end
