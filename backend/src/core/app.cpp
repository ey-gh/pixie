// src/core/app.cpp

#include "core/app.h"
#include "core/pg_pool.h"
#include "core/logger.h"
#include "util/env_loader.h"
#include "routes/clients.h"
#include "routes/ping.h"
#include "routes/dbtest.h"

#include <crow.h>

namespace pixie::core {

	int run_backend() {
		crow::SimpleApp app;

		// Load environment config
		std::string conn_str = pixie::util::get_env_value("PG_CONN_STRING", "backend");

		// Initialize DB pool
		init_pg_pool(conn_str, 10);

		// Register routes (more modular later)
		pixie::routes::register_ping(app);
		pixie::routes::register_dbtest(app);  // temporary until service refactor
		pixie::routes::register_client_routes(app);     // refactored to use singleton PgPool

		// Start HTTP server
		log_info("[app] Server running on http://localhost:18080");
		app.port(18080).multithreaded().run();

		return 0;
	}

}
