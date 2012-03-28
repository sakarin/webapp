module Spree
  CheckoutController.class_eval do

    before_filter :paypal_account, :only => [:paypal_payment, :order_opts]

    #---------------------------------------------------------------------------
    #- Check Store Before Send Data To Paypal
    #---------------------------------------------------------------------------
    #- send fake domain to paypal
    def paypal_account

      @preferences = Spree::Preference.find_by_key("spree/billing_integration/paypal_express/fake_domain/#{params[:payment_method_id]}")

      if Rails.env == "production"
        params[:host_with_port] = @preferences.value
      else
        params[:host_with_port] = @preferences.value + ":" + request.port.to_s

      end
    end

    #---------------------------------------------------------------------------
    #- Edit URL for Paypal Confirm
    #---------------------------------------------------------------------------
    def fixed_opts
      if Spree::PaypalExpress::Config[:paypal_express_local_confirm].nil?
        user_action = "continue"
      else
        user_action = Spree::PaypalExpress::Config[:paypal_express_local_confirm] == "t" ? "continue" : "commit"
      end

      { :description             => "Goods from #{Spree::Config[:site_name]}", # site details...

        #:page_style             => "foobar", # merchant account can set named config
        :header_image            => "https://#{Spree::Config[:site_url]}#{Spree::Config[:logo]}",
        :background_color        => "ffffff",  # must be hex only, six chars
        :header_background_color => "ffffff",
        :header_border_color     => "ffffff",
        :allow_note              => true,
        :locale                  => "#{request.protocol}#{params[:host_with_port]}" ,
        :req_confirm_shipping    => false,   # for security, might make an option later
        :user_action             => user_action

        # WARNING -- don't use :ship_discount, :insurance_offered, :insurance since
        # they've not been tested and may trigger some paypal bugs, eg not showing order
        # see http://www.pdncommunity.com/t5/PayPal-Developer-Blog/Displaying-Order-Details-in-Express-Checkout/bc-p/92902#C851
      }
    end

    #---------------------------------------------------------------------------
    #- Edit URL for Paypal Confirm
    #---------------------------------------------------------------------------
    def order_opts(order, payment_method, stage)
      items = order.line_items.map do |item|
        price = (item.price * 100).to_i # convert for gateway
        { :name        => item.variant.product.name,
          :description => (item.variant.product.description[0..120] if item.variant.product.description),
          :sku         => item.variant.sku,
          :quantity    => item.quantity,
          :amount      => price,
          :weight      => item.variant.weight,
          :height      => item.variant.height,
          :width       => item.variant.width,
          :depth       => item.variant.weight }
      end

      credits = order.adjustments.map do |credit|
        if credit.amount < 0.00
          { :name        => credit.label,
            :description => credit.label,
            :sku         => credit.id,
            :quantity    => 1,
            :amount      => (credit.amount*100).to_i }
        end
      end

      credits_total = 0
      credits.compact!
      if credits.present?
        items.concat credits
        credits_total = credits.map {|i| i[:amount] * i[:quantity] }.sum
      end

      if params[:host_with_port].nil?
        params[:host_with_port] = request.host_with_port
      end

      opts = { :return_url        => request.protocol + params[:host_with_port] + "/confirm/" + "orders/#{order.number}/checkout/paypal_confirm?payment_method_id=#{payment_method}",
               :cancel_return_url => request.protocol + params[:host_with_port] + "/" + "orders/#{order.number}/edit",
               :order_id          => order.number,
               :custom            => order.number,
               :items             => items,
               :subtotal          => ((order.item_total * 100) + credits_total).to_i,
               :tax               => ((order.adjustments.map { |a| a.amount if ( a.source_type == 'Order' && a.label == 'Tax') }.compact.sum) * 100 ).to_i,
               :shipping          => ((order.adjustments.map { |a| a.amount if a.source_type == 'Shipment' }.compact.sum) * 100 ).to_i,
               :money             => (order.total * 100 ).to_i }

      # add correct tax amount by subtracting subtotal and shipping otherwise tax = 0 -> need to check adjustments.map
      opts[:tax] = (order.total*100).to_i - opts.slice(:subtotal, :shipping).values.sum

      if stage == "checkout"
        opts[:handling] = 0

        opts[:callback_url] = spree_root_url + "paypal_express_callbacks/#{order.number}"
        opts[:callback_timeout] = 3
      elsif stage == "payment"
        #hack to add float rounding difference in as handling fee - prevents PayPal from rejecting orders
        #because the integer totals are different from the float based total. This is temporary and will be
        #removed once Spree's currency values are persisted as integers (normally only 1c)
        opts[:handling] =  (order.total*100).to_i - opts.slice(:subtotal, :tax, :shipping).values.sum
      end

      opts
    end

  end
end
