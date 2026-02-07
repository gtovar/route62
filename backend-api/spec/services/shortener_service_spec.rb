require "rails_helper"

RSpec.describe ShortenerService do
  let(:service) { ShortenerService }

  describe ".encode" do
    it "encodes a known id using the shuffled alphabet" do
      expect(service.encode(100)).to eq("7I")
    end

    it "encodes boundary values around the first base transition" do
      expect(service.encode(1)).to eq("7")
      expect(service.encode(61)).to eq("t")
      expect(service.encode(62)).to eq("70")
    end

    it "raises an error when id is zero" do
      expect { service.encode(0) }
        .to raise_error(ArgumentError, "id must be a positive integer")
    end

    it "raises an error when id is negative" do
      expect { service.encode(-1) }
        .to raise_error(ArgumentError, "id must be a positive integer")
    end

    it "raises an error when id is not an integer" do
      expect { service.encode("100") }
        .to raise_error(ArgumentError, "id must be a positive integer")
      expect { service.encode(10.5) }
        .to raise_error(ArgumentError, "id must be a positive integer")
      expect { service.encode(nil) }
        .to raise_error(ArgumentError, "id must be a positive integer")
    end
  end

  describe ".decode" do
    it "decodes a known slug back to the original id" do
      expect(service.decode("7I")).to eq(100)
    end

    it "decodes one-character slugs" do
      expect(service.decode("7")).to eq(1)
      expect(service.decode("t")).to eq(61)
    end

    it "raises an error when slug is empty" do
      expect { service.decode("") }
        .to raise_error(ArgumentError, "slug must be a non-empty string")
    end

    it "raises an error when slug is not a string" do
      expect { service.decode(nil) }
        .to raise_error(ArgumentError, "slug must be a non-empty string")
      expect { service.decode(123) }
        .to raise_error(ArgumentError, "slug must be a non-empty string")
    end

    it "raises an error when slug contains invalid characters" do
      expect { service.decode("7-") }
        .to raise_error(ArgumentError, "slug contains invalid characters")
    end
  end

  describe "round-trip behavior" do
    it "returns original id after encode then decode" do
      ids = [1, 2, 61, 62, 63, 100, 9999, 123_456_789]

      ids.each do |id|
        slug = service.encode(id)
        decoded_id = service.decode(slug)
        expect(decoded_id).to eq(id)
      end
    end
  end
end
