module Spree
  class Location < ActiveRecord::Base
    validates_presence_of :name
  end
end

