class Order < ApplicationRecord
	validates_presence_of :first_name, :last_name, :email, :phone

  after_save :request_qisstpay_api

  private
		def request_qisstpay_api
			self.update_column(:payment_link, "https://facebook.com/ammarvellous")
		end


end
