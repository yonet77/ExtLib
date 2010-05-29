puts "Copying Files...."

%w(javascripts stylesheets).each do |dir|
  source = File.expand_path(File.join(File.dirname(__FILE__), '..', 'ExtLib', 'ext', dir))
  target = File.join(RAILS_ROOT, 'public', dir, 'ext')
  FileUtils.cp_r(source, target, :verbose => true)
end

puts "Files Copied...."
