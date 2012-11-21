# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "corner_stones/version"

Gem::Specification.new do |s|
  s.name        = "corner_stones"
  s.version     = CornerStones::VERSION
  s.authors     = ["Yves Senn"]
  s.email       = ["yves.senn@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{capybara building blocks for acceptance tests}
  s.description = %q{This gem makes it easy to build PageObjects and make your acceptance tests more object oriented. It includes a implementations for common elements like tables, tabs, navigations etc.}

  s.rubyforge_project = "corner_stones"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  s.add_development_dependency "minitest", '~> 3.3.0'
  s.add_runtime_dependency "capybara", '~> 1.1.3'
end
