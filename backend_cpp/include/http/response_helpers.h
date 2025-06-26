// include/http/response_helpers.h
#pragma once

#include <crow.h>
#include <string>

namespace pixie::http {

	// Build a standard error JSON response: { "error": "..." }
	crow::response json_error(int status, const std::string& message);

	// Build a JSON success response from wvalue (pre-formatted Crow JSON object)
	crow::response json_success(int status, const crow::json::wvalue& data);

} // namespace pixie::http
