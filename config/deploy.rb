set :application, "cap_test"
set :repository,  "git@github.com:arktisklada/capistrano_test.git"


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
      run "#{try_sudo} ln -s #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end

  desc "Run bundle install to ensure all gem requirements are met"
  task :bundle do
    run "cd #{release_path} && RAILS_ENV=#{fetch(:rails_env)} bundle install  --without development test --quiet "
    # run "cd #{current_path} && bundle install  --without=test --no-update-sources"
  end


  task :start do
    run "cd #{deploy_to}/current; bundle exec thin start -C config/thin.yml"
  end

  desc "Stop the Thin processes"
  task :stop do
    run "cd #{deploy_to}/current; bundle exec thin stop -C config/thin.yml"
  end

  desc "Restart the Thin processes"
  task :restart do
    run "cd #{deploy_to}/current; bundle exec thin restart -C config/thin.yml"
  end
end


before "deploy:assets:precompile", "deploy:symlink_config_files"
before "deploy:migrate", "deploy:bundle"
before "deploy:restart", "deploy:migrate"
after "deploy:restart", "deploy:cleanup"
after :finished, 'deploy:restart'
