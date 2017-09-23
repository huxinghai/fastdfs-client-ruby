# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastdfs-client/version'

Gem::Specification.new do |spec|
  spec.name          = "fastdfs-client"
  spec.version       = Fastdfs::Client::VERSION
  spec.authors       = ["Ka Ka"]
  spec.email         = ["huxinghai1988@gmail.com"]
  spec.description   = "fastdfs upload file client for ruby"
  spec.summary       = "fastdfs upload file client for ruby"
  spec.homepage      = "https://github.com/huxinghai1988/fastdfs-client-ruby.git"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rspec", "~> 3.4"
  if RUBY_VERSION.start_with?('2')
    # Call 'byebug' anywhere in the code to stop execution and get a debugger console
    spec.add_development_dependency "byebug"
  else
    # Call 'debugger' anywhere in the code to stop execution and get a debugger console
    spec.add_development_dependency "debugger", "~> 1.6"
  end
end