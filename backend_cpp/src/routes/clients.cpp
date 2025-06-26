// src/routes/clients.cpp

#include "routes/clients.h"
#include "validators/client_validator.h"
#include "services/client_service.h"
#include "core/logger.h"
#include "http/response_helpers.h"

#include <nlohmann/json.hpp>
#include <crow.h>

using json = nlohmann::json;

namespace pixie::routes {

	void register_client_routes(crow::SimpleApp& app) {

		// POST /clients
		CROW_ROUTE(app, "/clients").methods(crow::HTTPMethod::POST)(
			[](const crow::request& req) {
				if (req.body.length() > 10 * 1024) {
					return pixie::http::json_error(413, "Payload too large");
				}

				try {
					auto body = json::parse(req.body);
					auto input = pixie::validators::validate_client_json(body);
					auto result = pixie::services::create_client(input);

					crow::json::wvalue response;
					response["id"] = result.id;
					response["created_at"] = result.created_at;

					return pixie::http::json_success(201, response);
				}
				catch (const std::exception& e) {
					pixie::core::log_error(std::string("[POST /clients] ") + e.what());
					return pixie::http::json_error(400, "Invalid input or database error");
				}
			}
			);

		// GET /clients
		CROW_ROUTE(app, "/clients").methods(crow::HTTPMethod::GET)([] {
			try {
				auto results = pixie::services::get_all_clients();

				crow::json::wvalue response = crow::json::wvalue::list(results.size());
				for (size_t i = 0; i < results.size(); ++i) {
					response[i]["id"] = results[i].id;
					response[i]["first_name"] = results[i].first_name;
					response[i]["last_name"] = results[i].last_name;
					if (results[i].dob.has_value()) {
						response[i]["dob"] = results[i].dob.value();
					}
					else {
						response[i]["dob"] = nullptr;
					}
				}

				return pixie::http::json_success(200, response);
			}
			catch (const std::exception& e) {
				pixie::core::log_error(std::string("[GET /clients] ") + e.what());
				return pixie::http::json_error(500, "Internal server error");
			}
			});
	}

}
