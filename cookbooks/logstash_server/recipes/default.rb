# requires Java runtime environment

# run apt-get update

execute "apt-get update" do
  command "apt-get update"
  ignore_failure true
  action :run
end

# install java
package "openjdk-7-jre" do
  action :install
end

# create users
user "logstash" do
  home "/opt/logstash-#{node[:logstash][:version]}/"
  shell "/bin/bash"
end

user "elasticsearch" do
  home "/opt/elasticsearch-#{node[:elasticsearch][:version]}/"
  shell "/bin/bash"
end

# create directories

directory "/opt/elasticsearch-#{node[:elasticsearch][:version]}/" do
  user 'elasticsearch'
  group 'elasticsearch'
  mode '0755'
end

directory "/etc/elasticsearch" do
  user 'elasticsearch'
  group 'elasticsearch'
  mode '0755'
end

directory "/opt/logstash-#{node[:logstash][:version]}/" do
  user 'logstash'
  group 'logstash'
  mode '0755'
end

directory "/etc/logstash-#{node[:logstash][:version]}/" do
  user 'logstash'
  group 'logstash'
  mode '0755'
end

directory "/var/log/logstash-#{node[:logstash][:version]}/" do
  user 'logstash'
  group 'logstash'
  mode '0755'
end

directory "/etc/redis-server" do
  user 'redis'
  group 'redis'
  mode '0755'
end

directory "/var/www/" do
  user 'root'
  group 'root'
  mode '0755'
end

directory "/var/www/kibana" do
  user 'root'
  group 'root'
  mode '0755'
end

# install packages

bash 'install elasticsearch' do
  not_if "/opt/elasticsearch-#{node[:elasticsearch][:version]}/elasticsearch --version | grep -q '#{node[:elasticsearch][:version]}'" #maintain idempotency if package already exists
  user "root"
  cwd "/opt/elasticsearch-#{node[:elasticsearch][:version]}/"
  code <<-EOH
    wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{node[:elasticsearch][:version]}.deb
    dpkg -i elasticsearch-#{node[:elasticsearch][:version]}.deb
    mv elasticsearch-#{node[:elasticsearch][:version]}.deb /var/cache/apt/archives
  EOH
end

bash 'install logstash' do
  not_if {File.exists?("/opt/logstash-#{node[:logstash][:version]}/bin/logstash.bat")} #maintain idempotency if files already exists
  user "root"
  cwd "/opt/"
  code <<-EOH
    wget https://download.elasticsearch.org/logstash/logstash/logstash-#{node[:logstash][:version]}.tar.gz
    tar -zxf logstash-#{node[:logstash][:version]}.tar.gz
    mv logstash-#{node[:logstash][:version]}.tar.gz /tmp/
  EOH
end

bash 'Kibana' do
  not_if {File.exists?("/opt/kibana-#{node[:kibana][:version]}/build.txt")} #maintain idempotency if files already exists
  user "root"
#  cwd "/opt/kibana-#{node[:kibana][:version]}/"
  cwd "/opt/"
  code <<-EOH
    wget https://download.elasticsearch.org/kibana/kibana/kibana-#{node[:kibana][:version]}.tar.gz
    tar -zxf kibana-#{node[:kibana][:version]}.tar.gz
    mv kibana-#{node[:kibana][:version]}.tar.gz /tmp/
    cp -R /opt/kibana-#{node[:kibana][:version]} /var/www/kibana
  EOH
end

package 'redis-server' do
  action :install
end

package 'nginx' do
  action :install
end

# configuration files

# elasticsearch configs

template '/etc/default/elasticsearch' do
  user 'elasticsearch'
  group 'elasticsearch'
  mode '0644'
  #notifies :restart, 'service[elasticsearch]'   #(this tells service to restart if config changes)
end

template '/etc/elasticsearch/elasticsearch.yml' do
  user 'elasticsearch'
  group 'elasticsearch'
  mode '0644'
  #notifies :restart, 'service[elasticsearch]'   #(this tells service to restart if config changes)
end

# redis config 

template '/etc/redis-server/redis.conf' do
  user 'redis'
  group 'redis'
  mode '0644'
  #notifies :restart, 'service[redis-server]'   #(this tells service to restart if config changes)
end

# Logstash config

template "/etc/logstash-#{node[:logstash][:version]}/server.conf" do
  user 'logstash'
  group 'logstash'
  mode '0644'
  #notifies :restart, 'service[logstash]'   #(this tells service to restart if config changes)
end

template '/etc/nginx/sites-available/default' do
  user 'root'
  group 'root'
  mode '0644'
  #notifies :restart, 'service[redis-server]'   #(this tells service to restart if config changes)
end




