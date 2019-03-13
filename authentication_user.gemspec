# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'authentication_user/version'

Gem::Specification.new do |spec|
  spec.name          = "authentication_user"
  spec.version       = AuthenticationUser::VERSION
  spec.authors       = ["Alexandr S"]
  spec.email         = ["alexandr@avaio-media.ru"]

  spec.summary       = %q{Users data and user sessions.}
  spec.description   = %q{Simple authentication for user and manual registration in master branch. 
                         Registration by confirm email in with_confirmation branch.
                         OAuth2 in branch oauth2 }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency 'activesupport', '~>3.2'
  spec.add_dependency 'railties', '~>3.2'

  spec.add_dependency 'cancancan'
end
