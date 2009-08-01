set :application, "musikschule"
set :repository,  "/var/www/htdocs/web4/files/repositories/git/musikschule.git"
set :local_repository,  "~/ruby/railsTest/musikschule/.git"
set :server, "railshosting.de"

set :deploy_to, "/var/www/htdocs/web4/files/rails/#{application}"
set :symlink_path, "/var/www/htdocs/web4/html/rails/#{application}"

set :scm, :git

set :user, "web4"
ssh_options[:port] = 981
set :use_sudo, false

set :deploy_via, :remote_cache

role :app, server
role :web, server
role :db,  server, :primary => true

# copy shared files after update
task :update_config, :roles => :app do
  run "cp -Rf #{shared_path}/config/* #{release_path}/config/"
end

# create symlink after setup
task :symlink_config, :roles => :app do
  run "mkdir -p /var/www/htdocs/#{user}/html/rails"
  run "ln -nfs #{current_path} #{symlink_path}"
end

after "deploy:setup", :symlink_config
after "deploy:update_code", :update_config

# mod_rails (phusion_passenger) stuff
namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end 
  
  [:start, :stop].each do |t|
    desc "start/stop is not necessary with mod_rails"
    task t, :roles => :app do 
      # nothing
    end
  end
end

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

#role :app, "your app-server here"
#role :web, "your web-server here"
#role :db,  "your db-server here", :primary => true
