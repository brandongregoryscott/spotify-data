# frozen_string_literal: true

require 'bundler/setup'
require 'git'
require 'date'
require 'pathname'
require 'logger'
require 'optparse'

def main
  logger = Logger.new($stdout)
  git = Git.open(Pathname('.'), log: logger)

  options = parse_options

  configure_git_user(git)
  checkout_branch(git, options)
end

def configure_git_user(git)
  git.config('user.name', 'github-actions[bot]')
  git.config('user.email', '41898282+github-actions[bot]@users.noreply.github.com')
  git.config('pull.rebase', 'false')
end

def checkout_branch(git, options)
  git.fetch('origin', unshallow: true) unless options[:skip_pull]

  branch_name = current_date
  is_new_branch = !git.is_branch?(branch_name)

  git.checkout(branch_name, new_branch: is_new_branch)

  return if options[:skip_pull]

  git.pull('origin', branch_name) unless is_new_branch
  git.pull('origin', 'main')
end

def parse_options
  options = {}

  OptionParser.new do |opts|
    opts.banner = 'Usage: ruby scripts/checkout_branch.rb [options]'

    opts.on('--skip-pull [cache-matched-key]',
            'Whether to skip fetching/pulling from the remote branch in the event of a cache hit') do |skip_pull|
      options[:skip_pull] = !skip_pull.nil? && !skip_pull.empty?
    end
  end.parse!

  options
end

def current_date
  DateTime.now.strftime('%Y-%m-%d')
end

main
