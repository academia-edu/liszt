require 'liszt'
require 'rails'

module Liszt
  class Railtie < Rails::Railtie
    config.after_initialize do
      ActiveRecord::Base.extend Liszt
    end
  end
end