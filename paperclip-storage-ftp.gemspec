# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.authors       = ["Sebastian Röbke"]
  gem.email         = ["sebastian.roebke@xing.com"]
  gem.description   = %q{Allow Paperclip attachments to be stored on FTP servers}
  gem.summary       = %q{Allow Paperclip attachments to be stored on FTP servers}
  gem.homepage      = "http://source.xing.com/architects/paperclip-storage-ftp"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "paperclip-storage-ftp"
  gem.require_paths = ["lib"]
  gem.version       = "0.0.2"

  gem.add_dependency("paperclip")

  gem.add_development_dependency("rspec")
  gem.add_development_dependency("rake")
end
