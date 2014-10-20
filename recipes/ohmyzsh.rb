#
# Cookbook Name:: oh_my_zsh
# Recipe:: default
#

##if node['oh_my_zsh']['users'].any?
 ## end

# for each listed user
#  home_directory = `cat /etc/passwd | grep "^#{user_hash[:login]}:" | cut -d ":" -f6`.chop
  login = node['oh_my_zsh']['login']
  theme = node['oh_my_zsh']['theme']
  plugins = node['oh_my_zsh']['plugins']

  package "zsh"

  home_directory = node['etc']['passwd'][login]['dir']

  git "#{home_directory}/.oh-my-zsh" do
    repository node['oh_my_zsh'][:repository]
    user login
    reference "master"
    action :sync
  end

  template "#{home_directory}/.zshrc" do
    source "zshrc.erb"
    owner login
    mode "644"
    action :create_if_missing
    variables({
      :user => login,
      :theme => theme || 'robbyrussell',
      :case_sensitive => false,
      :plugins => plugins || %w(git)
    })
  end

 user login do
   action :modify
   shell '/bin/zsh'
 end

 if platform?("debian", "ubuntu")
   execute "source /etc/profile to all zshrc" do
     command "echo 'source /etc/profile' >> /etc/zsh/zprofile"
     not_if "grep 'source /etc/profile' /etc/zsh/zprofile"
   end
 end
