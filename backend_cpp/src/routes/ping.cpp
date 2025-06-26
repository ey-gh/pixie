// src/routes/ping.cpp

#include "routes/ping.h"
#include "services/diagnostic_service.h"

namespace pixie::routes {

	void register_ping(crow::SimpleApp& app) {
		CROW_ROUTE(app, "/ping").methods(crow::HTTPMethod::GET)([] {
			return crow::response{ pixie::services::get_health_ping() };
			});
	}

}