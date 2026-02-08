class AuthTokenService
  def self.encode(payload)
    JWT.encode(payload.merge(exp: 24.hours.from_now.to_i), secret_key, "HS256")
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret_key, true, { algorithm: "HS256" })
    decoded.first
  end

  def self.secret_key
    Rails.application.secret_key_base
  end
end
