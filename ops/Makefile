.PHONY: test-backend test-shortener

test-backend:
	docker compose exec -e RAILS_ENV=test backend bundle exec rspec

test-shortener:
	docker compose exec -e RAILS_ENV=test backend bundle exec rspec spec/services/shortener_service_spec.rb
