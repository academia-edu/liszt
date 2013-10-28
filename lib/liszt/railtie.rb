module Liszt
  class Railtie < Rails::Railtie
    initializer 'liszt.extend_active_record' do
      ActiveRecord::Base.extend Liszt
    end
  end
end
