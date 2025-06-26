// src/validators/client_validator.cpp

#include "validators/client_validator.h"
#include "core/logger.h"
#include "validators/common_validation.h"

namespace pixie::validators {

	ClientInput validate_client_json(const nlohmann::json& body) {
		if (!body.contains("first_name") || !body["first_name"].is_string() || body["first_name"].get<std::string>().empty()) {
			throw std::runtime_error("first_name is required and must be a non-empty string");
		}
		if (!body.contains("last_name") || !body["last_name"].is_string() || body["last_name"].get<std::string>().empty()) {
			throw std::runtime_error("last_name is required and must be a non-empty string");
		}

		ClientInput input;
		input.first_name = body["first_name"];
		input.last_name = body["last_name"];

		if (body.contains("dob")) {
			if (!body["dob"].is_string() || !pixie::validators::is_valid_date(body["dob"])) {
				throw std::runtime_error("dob must be a string in YYYY-MM-DD format");
			}
			input.dob = body["dob"];
		}

		if (body.contains("email")) {
			if (!body["email"].is_string() || !pixie::validators::is_valid_email(body["email"])) {
				throw std::runtime_error("email must be a valid email string");
			}
			input.email = body["email"];
		}

		return input;
	}

}