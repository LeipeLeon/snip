# -*- encoding : utf-8 -*-
require "bundler/capistrano"
set :application, "burgr"

set :scm, :git
set :user, 'www-data'
set :group, 'www-data'
set :deploy_to, '/var/rails/burgr'
set :use_sudo, false
set :instance, "bwh4"

default_run_options[:pty] = true
set :repository,  "git@github.com:LeipeLeon/snip.git"
set :repository_cache, "git_master"
set :deploy_via, :remote_cache

set :scm_verbose, :true
set :keep_releases, 3

role :app, "bwh4"

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

  desc "symlinks to .yml in shared/config" 
  task :symlink_config do
    ['database'].each {|yml_file|
      # remove  the git version of yml_file.yml
      run "if [ -e \"#{release_path}/config/#{yml_file}.yml\" ] ; then rm #{release_path}/config/#{yml_file}.yml; fi"

      # als shared conf bestand nog niet bestaat
      run "if [ ! -e \"#{deploy_to}/#{shared_dir}/config/#{yml_file}.yml\" ] ; then cp #{deploy_to}/#{shared_dir}/#{repository_cache}/config/#{yml_file}.example.yml #{deploy_to}/#{shared_dir}/config/#{yml_file}.yml; fi"

      # link to the shared yml_file.yml
      run "ln -nfs #{deploy_to}/#{shared_dir}/config/#{yml_file}.yml #{release_path}/config/#{yml_file}.yml" 
    }
  end
  after "deploy:finalize_update", "deploy:symlink_config"
end
