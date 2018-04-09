class Chef::Recipe
  # Ensures $HOME is temporarily set to the given user. The original
  # $HOME is preserved and re-set after the block has been yielded
  # to.
  #
  # This is a workaround for CHEF-3940. TL;DR Certain versions of
  # `git` misbehave if configuration is inaccessible in $HOME.
  #
  # More info here:
  #
  #   https://github.com/git/git/commit/4698c8feb1bb56497215e0c10003dd046df352fa
  #
  def with_home_for_user(username, &block)

    time = Time.now.to_i

    ruby_block "set HOME for #{username} at #{time}" do
      block do
        ENV['OLD_HOME'] = ENV['HOME']
        ENV['HOME'] = begin
          require 'etc'
          Etc.getpwnam(username).dir
        rescue ArgumentError # user not found
          "/home/#{username}"
        end
      end
    end

    yield

    ruby_block "unset HOME for #{username} #{time}" do
      block do
        ENV['HOME'] = ENV['OLD_HOME']
      end
    end
  end
end
