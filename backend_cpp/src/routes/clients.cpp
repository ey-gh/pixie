// src/routes/clients.cpp

#include "routes/clients.h"
#include "services/client_service.h"
#include "dto/client_dto.h"
#include "error-handling/error.h"
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
                try {
                    json body = json::parse(req.body);
                    pixie::dto::ClientCreateDTO dto = pixie::dto::ClientCreateDTO::from_json(body);
                    auto result = pixie::services::create_client(dto);

                    nlohmann::json response;
                    response["id"] = result.id;
                    response["created_at"] = result.created_at;

                    return pixie::http::json_success(201, response);
                }
                catch (const pixie::error::BaseError& e) {
                    return e.to_response();
                }
                catch (const std::exception& e) {
                    return pixie::error::InternalError("Unexpected server error", e.what()).to_response();
                }
            }
            );

        // GET /clients
        CROW_ROUTE(app, "/clients").methods(crow::HTTPMethod::GET)(
            [] {
                try {
                    auto results = pixie::services::get_all_clients();

                    json response = json::array();
                    for (const auto& r : results) {
                        json client = {
                            {"id", r.id},
                            {"first_name", r.first_name},
                            {"last_name", r.last_name},
                            {"dob", r.dob.value_or(nullptr)},
                            {"created_at", r.created_at}
                        };
                        response.push_back(std::move(client));
                    }

                    return pixie::http::json_success(200, response);
                }
                catch (const pixie::error::BaseError& e) {
                    return e.to_response();
                }
                catch (const std::exception& e) {
                    return pixie::error::InternalError("Failed to fetch clients", e.what()).to_response();
                }
            }
            );
    }

}

