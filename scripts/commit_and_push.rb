# frozen_string_literal: true

require 'bundler/setup'
require 'git'
require 'json'
require 'date'
require 'pathname'
require 'logger'


def main
  logger = Logger.new(STDOUT)
  git = Git.open(Pathname('.'), log: logger)

  configure_git_user(git)
  branch_name = checkout_branch(git)

  git.add('output')
  git.commit(DateTime.now.iso8601)

  if current_hour.even?
    merge_and_delete_daily_branch(git, branch_name)
    return
  end

  git.push('origin', branch_name)
end

def configure_git_user(git)
  git.config('user.name', 'Github Actions')
  git.config('user.email', 'actions@users.noreply.github.com')
end

def checkout_branch(git)
  git.fetch('origin')
  
  branch_name = current_date
  is_new_branch = !git.is_branch?(branch_name)

  git.checkout(branch_name, new_branch: is_new_branch)

  git.pull('origin', branch_name)
  branch_name
rescue Git::FailedError
  branch_name
end

def merge_and_delete_daily_branch(git, branch_name)
  git.checkout('main')
  system("git merge --squash  #{branch_name}")
  git.commit(branch_name)
  git.push('origin', branch_name, delete: true)
  git.push('origin', 'main')
end

def current_date
  DateTime.now.strftime('%Y-%m-%d')
end

def current_hour
  # - flag drops then padding
  hour = DateTime.now.strftime('%-H')
  Integer(hour)
end

main
