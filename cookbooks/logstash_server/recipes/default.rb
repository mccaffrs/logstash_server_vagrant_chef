
# create users
user "logstash" do
  home "/opt/logstash-#{node[:logstash][:version]}/"
  shell "/bin/bash"
end

# create directories

directory "/opt/elasticsearch-#{node[:elasticsearch][:version]}/" do
  user 'logstash'
  group 'logstash'
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

package 'redis-server' do
  action :install
end

# configuration files

# elasticsearch configs

template '/etc/default/elasticsearch' do
  user 'logstash'
  group 'logstash'
  mode '0644'
  notifies :restart, 'service[elasticsearch]'   #(this tells service to restart if config changes)
end

template '/etc/elasticsearch/elasticsearch.yml' do
  user 'logstash'
  group 'logstash'
  mode '0644'
  notifies :restart, 'service[elasticsearch]'   #(this tells service to restart if config changes)
end
