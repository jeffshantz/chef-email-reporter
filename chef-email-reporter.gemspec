# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chef-email-reporter/version'

Gem::Specification.new do |spec|
  spec.name             = "chef-email-reporter"
  spec.version          = ChefEmailReporter::VERSION
  spec.authors          = ["Jeff Shantz"]
  spec.email            = ["jeff@csd.uwo.ca"]
  spec.summary          = %q{Sends chef-client errors via email.}
  spec.description      = %q{Sends chef-client errors via email.  More detailed than a simple chef_handler.}
  spec.homepage         = "http://jeffshantz.github.io/chef-email-reporter"
  spec.license          = "Apache 2.0"

  spec.files            = `git ls-files -z`.split("\x0")
  spec.executables      = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files       = spec.files.grep(%r{^(test|spec|features)/})
  spec.extra_rdoc_files = ["README.md", "LICENSE"]
  spec.require_paths    = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 0"

  spec.add_dependency "chef", "~> 11.14"
  spec.add_dependency "mail", "~> 2.6"
end
