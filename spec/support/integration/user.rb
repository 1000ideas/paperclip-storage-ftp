require "active_record"

ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => ":memory:"
)

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define do
  create_table :users
  add_column :users, :avatar_file_name, :string
  add_column :users, :avatar_content_type, :string
  add_column :users, :avatar_file_size, :integer
  add_column :users, :avatar_updated_at, :datetime
end

class User < ActiveRecord::Base
  include Paperclip::Glue

  has_attached_file :avatar,
    :storage  => :ftp,
    :styles   => { :medium => "50x50>", :thumb => "10x10>" },
    :path     => "/:id/:style/:filename",
    :ftp_servers => [
      {
        :host     => "127.0.0.1",
        :user     => "user1",
        :password => "secret1",
        :port     => 2121
      },
      {
        :host     => "127.0.0.1",
        :user     => "user2",
        :password => "secret2",
        :port     => 2121
      }
    ]
end
