#!/usr/bin/env rake
require 'bundler'

Bundler::GemHelper.install_tasks

desc 'Bundle the gem'
task :bundle do
  sh 'bundle install'
  sh 'gem build *.gemspec'
  sh 'gem install *.gem'
  sh 'rm *.gem'
end

task :spec do
  sh 'bundle exec rspec'
end

task :pronto do
  if ENV['TRAVIS_PULL_REQUEST']
    puts 'Running pronto on pronto'
    `gem install pronto-rubocop`
    commit = ENV['TRAVIS_COMMIT_RANGE'].split('..').first
    access_token =  ENV['GITHUB_ACCESS_TOKEN']
    `pronto exec -c #{commit} -f github -t #{access_token}`
  end
end

task(:default).clear
task default: [:bundle, :spec, :pronto]
