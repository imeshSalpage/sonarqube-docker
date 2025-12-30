sonar-scan:
	docker run --rm -v $(shell pwd)/..:/usr/src --network=app-network sonarsource/sonar-scanner-cli