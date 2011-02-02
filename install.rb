require 'fileutils'

puts "Type your git repository dir:"
repo = STDIN.gets.chomp

src =[]
src << File.join(File.dirname(__FILE__), 'lib', 'git_share.rb')
src << File.join(File.dirname(__FILE__), 'lib', 'git_share')
src << File.join(File.dirname(__FILE__), 'hooks')
dest = File.join(repo,'.git')


if (File.exists? dest)
  src.each do |source|
    FileUtils.cp_r(source, dest)
  end
end


