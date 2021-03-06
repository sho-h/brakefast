lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'brakefast/version'

Gem::Specification.new do |spec|
  spec.name          = "brakefast"
  spec.version       = Brakefast::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["Sho Hashimoto"]
  spec.email         = ["sho.hsmt@gmail.com"]
  spec.homepage      = "https://github.com/sho-h/brakefast"

  spec.summary       = "runtime brakeman notifier like bullet"
  spec.description   = "runtime brakeman notifier like bullet"
  spec.license     = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "uniform_notifier", "~> 1.9.0"
  spec.add_runtime_dependency "brakeman"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end

