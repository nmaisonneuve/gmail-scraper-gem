spec = Gem::Specification.new do |s|
  s.name = 'gmail-scraper'
  s.version = '0.1'
  s.summary = "Scrap Gmail's emails from its HTML Version."  
  s.files = Dir['lib/**/*.rb'] + Dir['spec/**/*.rb']
  s.require_path = 'lib'
  s.add_dependency('mechanize', '>= 0.9.3')
  s.author = "Nicolas Maisonneuve"
  s.email = "n.maisonneuve@gmail.com"
  s.homepage = "http://github.com/nmaisonneuve/gmail-scraper-gem"
end