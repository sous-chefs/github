guard 'spork' do
  watch('Gemfile')
  watch('spec/spec_helper.rb')     { :rspec }
  watch(%r{^spec/support/.+\.rb$}) { :rspec }
end

guard 'rspec', cli: "--color --drb --format Fuubar", all_on_start: false, all_after_pass: false do
  watch(%r{^spec/libraries/.+_spec\.rb$})

  watch(%r{^libraries/(.+)\.rb$})   { |m| "spec/libraries/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')      { "spec" }
end
