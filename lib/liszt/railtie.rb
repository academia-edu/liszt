require 'liszt'
require 'rails'

module Liszt
  class Railtie < Rails::Railtie
    initializer "extend ActiveRecord::Base" do
      ActiveRecord::Base.extend Liszt
    end
  end
end