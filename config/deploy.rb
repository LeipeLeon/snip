set :application, "snip"
set :user, 'berl'
set :use_sudo, false

set :scm, :git
default_run_options[:pty] = true
set :repository,  "git@github.com:LeipeLeon/snip.git"
set :repository_cache, "git_master"
set :deploy_via, :remote_cache
set :deploy_to, "/home/#{user}/apps/#{application}"

set :scm_verbose, :true
set :use_sudo, false
set :keep_releases, 3

role :app, "web"
role :web, "web"
role :db,  "web", :primary => true

set :runner, user
set :admin_runner, user

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
  task :cold do
    deploy.update
    deploy.restart
  end
end
