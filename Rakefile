require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

MASTER_REPOSITORY = if ENV['GH_TOKEN']
    'https://$GH_TOKEN@github.com/rejasupotaro/rejasupotaro.github.io'
  else
    'git@github.com:rejasupotaro/rejasupotaro.github.io.git'
  end
PUBLISH_BRANCH = 'master'
DEST_DIR = 'build'

def initialize_repository(repository, branch)
  require 'fileutils'

  if Dir["#{DEST_DIR}/.git"].empty?
    FileUtils.rm_rf DEST_DIR
    system "git clone --quiet #{repository} #{DEST_DIR} 2> /dev/null"
  end

  Dir.chdir DEST_DIR do
    sh "git checkout --orphan #{branch}"
  end
end

def update_repository(branch)
  Dir.chdir DEST_DIR do
    sh 'git fetch origin'
    sh "git reset --hard origin/#{branch}"
  end
end

def build
  sh 'bundle exec rspec'
end

def clean
  require 'fileutils'

  Dir["#{DEST_DIR}/*"].each do |file|
    FileUtils.rm_rf file
  end
end

def push_to_gh_pages(repository, branch)
  sha1, _ = `git log -n 1 --oneline`.strip.split(' ')

  Dir.chdir DEST_DIR do
    sh 'git init'
    sh 'git add --all .'
    sh "git commit -m 'Update with #{sha1}'"
    sh "git push #{repository} #{branch} -f"
  end
end

desc 'Setup origin repository for GitHub pages'
task :setup do
  initialize_repository MASTER_REPOSITORY, PUBLISH_BRANCH
  update_repository PUBLISH_BRANCH
end

desc 'Clean built files'
task :clean do
  clean
end

desc 'Build sites'
task :build do
  clean
  build
end

desc 'Publish website'
task :publish do
  push_to_gh_pages MASTER_REPOSITORY, PUBLISH_BRANCH
end
