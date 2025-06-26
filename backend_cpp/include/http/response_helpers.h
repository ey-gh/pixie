// include/http/response_helpers.h
#pragma once

#include <crow.h>
#include <string>
#include <nlohmann/json.hpp>

namespace pixie::http {

	// Build a standard error JSON response: { "error": "..." }
	crow::response json_error(int status, const std::string& message);

	// Build a JSON success response from wvalue (pre-formatted Crow JSON object)
	crow::response json_success(int status, const nlohmann::json& data);

} // namespace pixie::http
