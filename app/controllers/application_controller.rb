class ApplicationController < ActionController::Base
  protect_from_forgery

  def location_block
    #@geo = Geokit::Geocoders::MultiGeocoder.geocode("216.113.188.64")
    @geo = Geokit::Geocoders::MultiGeocoder.geocode(request.ip)
    #@geo = Geokit::Geocoders::MultiGeocoder.geocode("124.122.152.111")

    logger.debug request.ip

    if "124.122.152.111" == request.ip
      logger.debug "location0"

    elsif not Spree::Location.where(:country => @geo.country_code, :state => "", :zip => "", :city => "").blank?
      @location = Spree::Location.where(:country => @geo.country_code, :state => "", :zip => "", :city => "")
      logger.debug "location1"
      redirect_to "#{@location.last.code}"

    elsif not Spree::Location.where(:country => @geo.country_code, :state => @geo.state, :zip => "", :city =>"").blank?
      @location = Spree::Location.where(:country => @geo.country_code, :state => @geo.state, :zip => "", :city =>"")
      logger.debug "location2"
      redirect_to "#{@location.last.code}"

    elsif not Spree::Location.where(:country => @geo.country_code, :state => @geo.state, :zip => @geo.zip, :city => "").blank?
      @location = Spree::Location.where(:country => @geo.country_code, :state => @geo.state, :zip => @geo.zip, :city => "")
          logger.debug "location3"
      redirect_to "#{@location.last.code}"

    elsif not Spree::Location.where(:country => @geo.country_code, :state => @geo.state, :zip => @geo.zip, :city => @geo.city).blank?
      @location = Spree::Location.where(:country => @geo.country_code, :state => @geo.state, :zip => @geo.zip, :city => @geo.city)
          logger.debug "location4"
      redirect_to "#{@location.last.code}"

    else
      logger.debug "NONE US"

    end

  end
end
