require "spec_helper"

describe Paperclip::Storage::Ftp::Server do
  before(:each) do
    Paperclip::Storage::Ftp::Server.clear_connections
  end

  let(:server) { Paperclip::Storage::Ftp::Server.new }

  context "initialize" do
    it "accepts options to initialize attributes" do
      options = {
        :host     => "ftp.example.com",
        :user     => "user",
        :password => "password",
        :port     => 2121,
        :passive  => false
      }
      server = Paperclip::Storage::Ftp::Server.new(options)
      server.host.should     == options[:host]
      server.user.should     == options[:user]
      server.password.should == options[:password]
      server.port.should     == options[:port]
      server.passive.should  == options[:passive]
    end

    it "sets a default port" do
      server = Paperclip::Storage::Ftp::Server.new
      server.port.should == Net::FTP::FTP_PORT
    end

    it "sets passive to true by default" do
      server = Paperclip::Storage::Ftp::Server.new
      server.passive.should be_true
    end
  end

  context "#file_exists?" do
    before do
      server.stub(:connection).and_return(double("connection"))
    end

    it "returns true if the file exists on the server" do
      server.connection.should_receive(:nlst).with("/files/original").and_return(["foo.jpg"])
      server.file_exists?("/files/original/foo.jpg").should be_true
    end

    it "recognizes complete file paths correctly" do
      server.connection.should_receive(:nlst).with("/files/original").and_return(["/files/original/foo.jpg"])
      server.file_exists?("/files/original/foo.jpg").should be_true
    end

    it "returns false if the file does not exist on the server" do
      server.connection.should_receive(:nlst).with("/files/original").and_return([])
      server.file_exists?("/files/original/foo.jpg").should be_false
    end

    it "returns false if the ftp server responds with a FTPTempError" do
      server.connection.should_receive(:nlst).with("/files/original").and_raise(Net::FTPTempError)
      server.file_exists?("/files/original/foo.jpg").should be_false
    end
  end

  context "#get_file" do
    before do
      server.stub(:connection).and_return(double("connection"))
    end

    it "returns the file object" do
      server.connection.should_receive(:getbinaryfile).with("/files/original.jpg", "/tmp/original.jpg")
      server.get_file("/files/original.jpg", "/tmp/original.jpg")
    end
  end

  context "#put_file" do
    before do
      server.stub(:connection).and_return(double("connection"))
    end

    it "stores the file on the server" do
      server.should_receive(:mkdir_p).with("/files")
      server.connection.should_receive(:putbinaryfile).with("/tmp/original.jpg", "/files/original.jpg")
      server.put_file("/tmp/original.jpg", "/files/original.jpg")
    end
  end

  context "#delete_file" do
    before do
      server.stub(:connection).and_return(double("connection"))
    end

    it "deletes the file on the server" do
      server.connection.should_receive(:delete).with("/files/original.jpg")
      server.delete_file("/files/original.jpg")
    end
  end

  context "#connection" do
    it "returns the reconnected connection for the given server (to avoid closed socket errors)" do
      connection = double("connection")
      server.should_receive(:build_connection).once.and_return(connection)
      connection.should_receive(:close).twice
      connection.should_receive(:connect).with(server.host, server.port).twice
      connection.should_receive(:login).with(server.user, server.password).twice
      2.times { server.connection.should == connection }
    end
  end

  context "#build_connection" do
    it "returns an ftp connection for the given server" do
      connection = double("connection")
      Net::FTP.should_receive(:new).and_return(connection)
      connection.should_receive(:passive=).with(server.passive)
      connection.should_receive(:connect).with(server.host, server.port)
      server.build_connection.should == connection
    end
  end

  context "mkdir_p" do
    before do
      server.stub(:connection).and_return(double("connection"))
    end

    it "creates the directory and all its parent directories" do
      server.connection.should_receive(:mkdir).with("/").ordered
      server.connection.should_receive(:mkdir).with("/files").ordered
      server.connection.should_receive(:mkdir).with("/files/foo").ordered
      server.connection.should_receive(:mkdir).with("/files/foo/bar").ordered
      server.mkdir_p("/files/foo/bar")
    end

    it "does not stop on Net::FTPPermError" do
      server.connection.should_receive(:mkdir).with("/").and_raise(Net::FTPPermError)
      server.connection.should_receive(:mkdir).with("/files")
      server.mkdir_p("/files")
    end
  end
end
