require File.join(File.dirname(__FILE__), '..', '..', 'git_share')
require 'daemons'

Daemons.run_proc('git_share_queue', :monitor => true, :log_output => true) do
  GitShare::Queue.unqueue(:all)
  sleep(10)
 end

