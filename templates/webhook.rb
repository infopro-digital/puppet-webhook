require 'sinatra'
require 'json'


post '/payload' do
  # User customization
  repo_puppetfile = "<%= @repo_puppetfile %>"
  repo_hieradata  = "<%= @repo_hieradata %>"

  push = JSON.parse(request.body.read)
  logger.info("json payload: #{push.inspect}")

  repo_name   = push['repository']['name']
  repo_ref    = push['ref']
  ref_array   = repo_ref.split("/")
  ref_type    = ref_array[1]
  branch_name = ref_array[2]
  logger.info("repo name = #{repo_name}")
  logger.info("repo ref = #{repo_ref}")
  logger.info("branch = #{branch_name}")

  # Check if the repository contains Puppetfile or hieradata
  if repo_name == repo_puppetfile || repo_name == repo_hieradata
    logger.info("Deploying r10k for environment '#{branch_name}'")
    deploy_env(branch_name)
  else
    logger.info("Deploying puppet module '#{repo_name}' from branch '#{branch_name}'")
    deploy_module(repo_name)
  end
end

# Some defines.
def deploy_env(branchname)
  deploy_cmd = "/usr/bin/r10k deploy environment #{branchname} -pv"
  `#{deploy_cmd}`
end

def deploy_module(modulename)
  deploy_cmd = "/usr/bin/r10k deploy module #{modulename} -v"
  `#{deploy_cmd}`
end
