// include/validators/client_validator.h
#pragma once

#include <string>
#include <optional>
#include <nlohmann/json.hpp>

namespace pixie::validators {

	struct ClientInput {
		std::string first_name;
		std::string last_name;
		std::optional<std::string> dob;
		std::optional<std::string> email;
	};

	// Throws std::runtime_error on failure
	ClientInput validate_client_json(const nlohmann::json& body);

}
