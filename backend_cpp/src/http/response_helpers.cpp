// src/http/response_helpers.cpp

#include "http/response_helpers.h"
#include <nlohmann/json.hpp>

namespace pixie::http {

	crow::response json_error(int status, const std::string& message) {
		nlohmann::json err = {
			{ "error", message }
		};
		return crow::response{ status, err.dump() };
	}

	crow::response json_success(int status, const nlohmann::json& data) {
		return crow::response{ status, data.dump() };
	}
}
