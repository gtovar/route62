class ShortenerService
  # Shuffled Base62 alphabet.
  ALPHABET = "07ELSZgnu18FMTahov29GNUbipw3AHOVcjqx4BIPWdkry5CJQXelsz6DKRYfmt".freeze
  BASE = ALPHABET.length

  def self.encode(id)
    unless id.is_a?(Integer) && id > 0
      raise ArgumentError, "id must be a positive integer"
    end

    encoded_slug = ""
    current_id = id

    while current_id > 0
      char_position = current_id % BASE
      encoded_slug = ALPHABET[char_position] + encoded_slug
      current_id /= BASE
    end

    encoded_slug
  end

  def self.decode(slug)
    unless slug.is_a?(String) && !slug.empty?
      raise ArgumentError, "slug must be a non-empty string"
    end

    decoded_id = 0

    slug.each_char do |character|
      char_position = ALPHABET.index(character)
      raise ArgumentError, "slug contains invalid characters" if char_position.nil?

      decoded_id = (decoded_id * BASE) + char_position
    end

    decoded_id
  end
end
