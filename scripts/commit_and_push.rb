# frozen_string_literal: true

require 'bundler/setup'
require 'git'
require 'date'
require 'pathname'
require 'logger'


def main
  logger = Logger.new($stdout)
  git = Git.open(Pathname('.'), log: logger)

  branch_name = git.current_branch

  git.add('output')
  git.commit(DateTime.now.iso8601)

  if current_hour == 23
    merge_and_delete_daily_branch(git, branch_name)
    return
  end

  git.push('origin', branch_name)
end

def merge_and_delete_daily_branch(git, branch_name)
  git.fetch('origin', unshallow: true)
  git.checkout('main')
  system("git merge --squash  #{branch_name}")
  git.commit(branch_name)
  git.push('origin', branch_name, delete: true)
  git.push('origin', 'main')
end

def current_hour
  # - flag drops then padding
  hour = DateTime.now.strftime('%-H')
  Integer(hour)
end

main
