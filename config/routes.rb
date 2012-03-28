Webapp::Application.routes.draw do

  mount Spree::Core::Engine, :at => '/'

end

Spree::Core::Engine.routes.append do
  match '/confirm/orders/:order_id/checkout/paypal_confirm(.:format)' => 'paypal_confirm#paypal', :via => [:get, :post]
end




