// src/routes/dbtest.cpp

#include "routes/dbtest.h"
#include "services/diagnostic_service.h"
#include "core/logger.h"

namespace pixie::routes {

	void register_dbtest(crow::SimpleApp& app) {
		CROW_ROUTE(app, "/dbtest").methods(crow::HTTPMethod::GET)([] {
			try {
				auto version = pixie::services::get_postgres_version();
				return crow::response(200, "PostgreSQL version: " + version);
			}
			catch (const std::exception& e) {
				pixie::core::log_error(std::string("[GET /dbtest] ") + e.what());
				return crow::response(500, "Database test failed");
			}
			});
	}

}
