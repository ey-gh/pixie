// src/main.cpp

#include <crow.h>
#include "util/env_loader.h"
#include "db/connection.h"
#include "routes/ping.h"
#include "routes/dbtest.h"
#include "routes/clients.h"

int main() {
	crow::SimpleApp app;

	// load postgresql connection string from .env.backend
	std::string conn_str;
	try {
		conn_str = pixie::util::get_env_value("PG_CONN_STRING", "backend");
	}
	catch (const std::exception& e) {
		std::cerr << "[main] Failed to load DB connection string: " << e.what() << std::endl;
		return 1;
	}

	std::cout << "Connected to database successfully.\n";

	// register all routes
	pixie::routes::register_ping(app);
	pixie::routes::register_dbtest(app, conn_str);
	pixie::routes::register_client_routes(app, conn_str);

	std::cout << "Server running on http://localhost:18080\n";

	// launch server
	app.port(18080).multithreaded().run();

}