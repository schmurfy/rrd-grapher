gem('watchr'); require 'watchr'


watch("spec/([^/]/)?.*_spec.rb") do |md|
  system "clear; echo '*** Running test: #{md[0]}'; bundle exec bacon #{md[0]}"
end

watch("^lib/rrd-grapher/(?:[^/]+/)?(.*)\.rb$") do |md|
  # check if a spec is available
  spec_path = "spec/unit/#{md[1]}_spec.rb"
  if File.exists?(spec_path)
    system "clear; echo '*** Running test: #{spec_path}'; bundle exec bacon #{spec_path}"
  end
end