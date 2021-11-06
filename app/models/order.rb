class Order < ApplicationRecord
	validates_presence_of :first_name, :last_name, :email, :phone

  after_save :request_qisstpay_api

	has_one :api_request, dependent: :destroy
	has_one :api_response, dependent: :destroy
	has_one :callback_response, dependent: :destroy

  private
		def request_qisstpay_api
			# Create a payload
			hash_body = {
				partner_id: "cartswing",
				fname: self.first_name,
				lname: self.last_name,
				email: self.email,
				phone_no: self.phone,
				ip_addr: "192.168.18.22",
				shipping_info: {
					addr1: "House no. D-182 Rufi Fountain",
					addr2: "Gulistan-e-Jauhar Block-19",
					state: "Sindh",
					city: "Karachi",
					zip: "75290"
				},
				billing_info: {
					addr1: "House no. D-182 Rufi Fountain",
					addr2: "Gulistan-e-Jauhar Block-19",
					state: "Sindh",
					city: "Karachi",
					zip: "75290"
				},
				total_amount: 1600,
				line_items: [
					{
						name: "Test product",
						sku: "test123",
						quantity: 1,
						type: "simple",
						category: "Fashion",
						unit_price: 1600,
						amount: 1600
					}
				],
				itemFlag: true,
				merchant_order_id: self.id,
				call_back_url: ENV['QISSTPAY_CALLBACK_URL'],
				redirect_url: ENV['QISSTPAY_REDIRECT_URL'] + self.id.to_s
			}

			# Send API request to QisstPay
			response = Faraday.post('https://sandbox.qisstpay.com/api/send-data') do |req|
				req.headers['Authorization'] = 'Basic 057c45455785e6f8dadcc315759e4b012d4e1062'
				req.headers['Content-Type'] = 'application/json'
				req.body = hash_body.to_json
			end

			# Save ApiRequest with the order ID
			ApiRequest.create(body: JSON.pretty_generate(hash_body), order_id: self.id)

			# Parse the response
			json_response = JSON.parse(response.body)

			# Save ApiResponse with the order ID
			ApiResponse.create(body: JSON.pretty_generate(json_response), order_id: self.id)
			
			# Update payment_link column in the order
			if json_response["success"]
				self.update_column(:payment_link, json_response["result"]["iframe_url"])
			end
		end
end
