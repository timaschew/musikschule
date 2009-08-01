set :application, "musikschule"
set :repository, "/var/www/htdocs/web4/files/repositories/git/test.git"
set :local_repository,  "~/ruby/railsTest/musikschule/.git"
set :domain, "railshosting.de"

set :deploy_to, "/var/www/htdocs/web4/files/rails/#{application}"
set :symlink_path, "/var/www/htdocs/web4/html/rails/#{application}"

set :scm, :git

set :user, "web4"
ssh_options[:port] = 981
set :use_sudo, false

set :deploy_via, :remote_cache

role :app, domain
role :web, domain
role :db,  domain, :primary => true

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
