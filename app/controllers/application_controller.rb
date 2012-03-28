class ApplicationController < ActionController::Base
  protect_from_forgery

  def location_block
    #@geo = Geokit::Geocoders::MultiGeocoder.geocode("216.113.188.64")

    # Geo Production
    @geo = Geokit::Geocoders::MultiGeocoder.geocode(request.ip)

    # Thai
    #@geo = Geokit::Geocoders::MultiGeocoder.geocode("124.122.152.111")

    logger.debug request.ip

    if "#{Spree::Config[:admin_ip]}" == request.ip

    elsif not Spree::Location.where(:country => @geo.country_code, :state => "", :zip => "", :city => "").blank?
      @location = Spree::Location.where(:country => @geo.country_code, :state => "", :zip => "", :city => "")

      redirect_to "#{@location.last.code}"

    elsif not Spree::Location.where(:country => @geo.country_code, :state => @geo.state, :zip => "", :city =>"").blank?
      @location = Spree::Location.where(:country => @geo.country_code, :state => @geo.state, :zip => "", :city =>"")

      redirect_to "#{@location.last.code}"

    elsif not Spree::Location.where(:country => @geo.country_code, :state => @geo.state, :zip => @geo.zip, :city => "").blank?
      @location = Spree::Location.where(:country => @geo.country_code, :state => @geo.state, :zip => @geo.zip, :city => "")

      redirect_to "#{@location.last.code}"

    elsif not Spree::Location.where(:country => @geo.country_code, :state => @geo.state, :zip => @geo.zip, :city => @geo.city).blank?
      @location = Spree::Location.where(:country => @geo.country_code, :state => @geo.state, :zip => @geo.zip, :city => @geo.city)

      redirect_to "#{@location.last.code}"

    else


    end

  end
end
