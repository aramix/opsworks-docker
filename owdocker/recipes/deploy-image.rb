include_recipe 'deploy'
include_recipe 'docker'

node[:deploy].each do |application, deploy|
  if node[:opsworks][:instance][:layers].first != deploy[:environment_variables][:layer]
    Chef::Log.warn("Skipping deploy::docker application #{application} as it is not deployed to this layer")
    next
  end

  opsworks_deploy_dir do
      user deploy[:user]
      group deploy[:group]
      path deploy[:deploy_to]
  end

  opsworks_deploy do
      deploy_data deploy
      app application
  end

  if deploy[:environment_variables][:registry_username]
    docker_registry "#{deploy[:environment_variables][:registry_url]}" do
      username deploy[:environment_variables][:registry_username]
      password deploy[:environment_variables][:registry_password]
      email deploy[:environment_variables][:registry_username]
    end
  end

  image_name = nil

  if deploy[:environment_variables][:registry_image]
    image_name = deploy[:environment_variables][:registry_image]
    docker_image image_name do
      tag deploy[:environment_variables][:registry_tag]
    end
  end

  if deploy[:environment_variables][:image_archive_name]
    current_dir = ::File.join(deploy[:deploy_to], 'current')
    image_name = ::File.basename(deploy[:environment_variables][:image_archive_name], ".*")
    docker_image image_name do
      input ::File.join(current_dir, deploy[:environment_variables][:image_archive_name])
      action :load
    end
  end

  Chef::Application.fatal!("Unable to determine image name, set either registry_image or image_archive_name") if !image

  docker_container "#{application}" do
    image image_name
    detach true
    hostname "#{node[:opsworks][:stack][:name]}-#{node[:opsworks][:instance][:hostname]}"
    env deploy[:environment_variables].map { |k,v| "#{k}=#{v}" if !k.match(/registry_password/)}.compact
    container_name application
    if deploy[:environment_variables][:ports]
      port deploy[:environment_variables][:ports].split(";")
    end
    if deploy[:environment_variables][:links]
      link deploy[:environment_variables][:links].split(";")
    end
    action :redeploy
  end
end
