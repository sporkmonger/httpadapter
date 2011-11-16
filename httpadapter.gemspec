# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "httpadapter"
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bob Aman"]
  s.date = "2011-11-16"
  s.description = "A library for translating HTTP request and response objects for various clients into a common representation.\n"
  s.email = "bob@sporkmonger.com"
  s.extra_rdoc_files = ["README.md"]
  s.files = ["lib/httpadapter", "lib/httpadapter/adapters", "lib/httpadapter/adapters/mock.rb", "lib/httpadapter/adapters/net_http.rb", "lib/httpadapter/adapters/rack.rb", "lib/httpadapter/adapters/typhoeus.rb", "lib/httpadapter/connection.rb", "lib/httpadapter/version.rb", "lib/httpadapter.rb", "spec/httpadapter", "spec/httpadapter/adapter_type_checking_spec.rb", "spec/httpadapter/adapters", "spec/httpadapter/adapters/mock_adapter_spec.rb", "spec/httpadapter/adapters/net_http_spec.rb", "spec/httpadapter/adapters/rack_spec.rb", "spec/httpadapter/adapters/typhoeus_spec.rb", "spec/httpadapter/connection_spec.rb", "spec/httpadapter_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/clobber.rake", "tasks/gem.rake", "tasks/git.rake", "tasks/metrics.rake", "tasks/rdoc.rake", "tasks/rubyforge.rake", "tasks/spec.rake", "tasks/yard.rake", "website/api", "website/coverage", "website/index.html", "website/specdoc", "CHANGELOG", "LICENSE", "Rakefile", "README.md"]
  s.homepage = "http://httpadapter.rubyforge.org/"
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "httpadapter"
  s.rubygems_version = "1.8.11"
  s.summary = "Package Summary"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<addressable>, ["~> 2.2.0"])
      s.add_development_dependency(%q<rake>, ["~> 0.8.3"])
      s.add_development_dependency(%q<rspec>, ["~> 1.1.11"])
      s.add_development_dependency(%q<launchy>, ["~> 0.3.2"])
      s.add_development_dependency(%q<diff-lcs>, ["~> 1.1.2"])
      s.add_development_dependency(%q<typhoeus>, ["~> 0.1.31"])
      s.add_development_dependency(%q<rack>, ["~> 1.2.0"])
    else
      s.add_dependency(%q<addressable>, ["~> 2.2.0"])
      s.add_dependency(%q<rake>, ["~> 0.8.3"])
      s.add_dependency(%q<rspec>, ["~> 1.1.11"])
      s.add_dependency(%q<launchy>, ["~> 0.3.2"])
      s.add_dependency(%q<diff-lcs>, ["~> 1.1.2"])
      s.add_dependency(%q<typhoeus>, ["~> 0.1.31"])
      s.add_dependency(%q<rack>, ["~> 1.2.0"])
    end
  else
    s.add_dependency(%q<addressable>, ["~> 2.2.0"])
    s.add_dependency(%q<rake>, ["~> 0.8.3"])
    s.add_dependency(%q<rspec>, ["~> 1.1.11"])
    s.add_dependency(%q<launchy>, ["~> 0.3.2"])
    s.add_dependency(%q<diff-lcs>, ["~> 1.1.2"])
    s.add_dependency(%q<typhoeus>, ["~> 0.1.31"])
    s.add_dependency(%q<rack>, ["~> 1.2.0"])
  end
end
