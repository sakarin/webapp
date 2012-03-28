class Spree::BillingIntegration::PaypalExpress < Spree::BillingIntegration
  preference :login, :string
  preference :password, :password
  preference :signature, :string
  preference :review, :boolean, :default => false
  preference :no_shipping, :boolean, :default => false
  preference :currency, :string, :default => 'USD'

  preference :fake_domain, :string

  def provider_class
    ActiveMerchant::Billing::PaypalExpressGateway
  end

end
