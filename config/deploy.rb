set :application, "cap_test"
set :repository,  "git@github.com:arktisklada/capistrano_test.git"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# role :web, "app.ga-instructors.com"                        # Your HTTP server, Apache/etc
# role :app, "app.ga-instructors.com"                        # This may be the same as your `Web` server
# role :db,  "app.ga-instructors.com", :primary => true      # This is where Rails migrations will run

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end


set :deploy_to, "/var/www/cap_test"
set :scm, :git
set :branch, "master"
set :user, "deployer"
set :scm_passphrase, "password"
set :use_sudo, false

set :rails_env, "production"
set :deploy_via, :copy
set :ssh_options, { :forward_agent => true, :port => 22 }
set :keep_releases, 5

server "app.ga-instructors.com", :app, :web, :db, :primary => true


namespace :deploy do
  desc "Symlink shared config files"
  task :symlink_config_files do
      run "#{ try_sudo } ln -s #{ deploy_to }/shared/config/database.yml #{ current_path }/config/database.yml"
  end
end


after "deploy", "deploy:symlink_config_files"
after "deploy", "deploy:migrate"
after "deploy", "deploy:restart"
after "deploy", "deploy:cleanup"
