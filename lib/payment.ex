defprotocol Payment do
  def create_payment(payment)
  def get_status(id)
  def update_payment(payment)
  def get_payments(payment)
end