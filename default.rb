report_execution
#
# Cookbook Name:: litc-chrome
# Recipe:: default
#
# Copyright 2015, SAP
#
# All rights reserved - Do Not Redistribute


src = node['litc-chrome']['src']

#Setting variables for install
if src == 'default' 
	chrome64 = node['kernel']['machine'] == 'x86_64' && !node['chrome']['32bit_only']	
	src =  chrome64 ? node['chrome']['msi_64'] : node['chrome']['msi']
		if chrome64 == 'msi_64' 
		filename = 'googlechromestandaloneenterprise64.msi'
		else
		filename = 'GoogleChromeStandaloneEnterprise.msi'
		end	
else 
	split1 = src.split("/")  #Validate installation reliable
	filename = split1[split1.length-1]
	if (filename.include?('.exe') || filename.include?('.msi'))
		check = true
	else
		check = false
	end
	Chef::Log.info "#### check res: #{check} on filename: #{filename} ###############"
	require "net/http"  #Validate source reliable
	require "uri" 
	proxy = URI.parse(node['litc-chrome']['proxy'])  
	uri = URI.parse(src) 
	http = Net::HTTP.new(uri.host, uri.port, proxy.host, proxy.port) 
	response = http.request(Net::HTTP::Get.new(uri.request_uri)) 
	code = response.code
	Chef::Log.info "#### The code is: #{code} ###############"
	
	if code == '200' && check == true
		Chef:: Log.info "#### The source is reliable! ####"
	else
		Chef:: Log.info "#### The source is unreliable! #####"
		return
	end
end

#Install Chrome
windows_package "Google Chrome" do
	installer_type :custom
	options '/quiet'
	source src	
	action :install
end	

#delete source file
cookbook_file "#{Chef::Config[:file_cache_path]}\\#{filename}" do
		action :delete
end 
