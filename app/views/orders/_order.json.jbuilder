json.extract! order, :id, :first_name, :last_name, :email, :phone, :status, :created_at, :updated_at
json.url order_url(order, format: :json)
