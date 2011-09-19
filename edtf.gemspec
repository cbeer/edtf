# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "edtf/version"

Gem::Specification.new do |s|
  s.name        = "edtf"
  s.version     = Edtf::VERSION
  s.authors     = ["Chris Beer"]
  s.email       = ["chris_beer@wgbh.org"]
  s.homepage    = ""
  s.summary     = %q{Library of Congress Extended Date Time Format}
  s.description = %q{http://www.loc.gov/standards/datetime/spec.html}

  s.rubyforge_project = "edtf"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "parslet"
  s.add_development_dependency "rspec", "~>2.0"
end
