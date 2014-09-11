Gem::Specification.new do |s|
  s.name        = "allowed"
  s.version     = "0.2.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tristan Dunn"]
  s.email       = "support@dribbble.com"
  s.homepage    = "https://github.com/dribbble/allowed"
  s.summary     = "Throttling of ActiveRecord model creations."
  s.description = "Throttling of ActiveRecord model creations."
  s.license     = "MIT"

  s.files        = Dir["lib/**/*"].to_a
  s.test_files   = Dir["spec/**/*"].to_a
  s.require_path = "lib"

  s.add_dependency "activerecord",  ">= 3"
  s.add_dependency "activesupport", ">= 3"

  s.add_development_dependency "appraisal", "1.0.0"
  s.add_development_dependency "bourne",    "1.5.0"
  s.add_development_dependency "rake",      "10.3.2"
  s.add_development_dependency "rspec",     "3.0.0"
  s.add_development_dependency "sqlite3",   "1.3.9"
end
