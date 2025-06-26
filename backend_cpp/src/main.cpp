// src/main.cpp

#include <crow.h>
#include "util/env_loader.h"
#include "db/connection.h"
#include "routes/ping.h"
#include "routes/dbtest.h"

int main() {
	crow::SimpleApp app;

	// load postgresql connection stsring from .env
	std::string conn_str;
	try {
		conn_str = pixie::util::load_connection_string();
	}
	catch (const std::exception& e) {
		std::cerr << "Failed to load .env: " << e.what() << std::endl;
		return 1;
	}

	// test db connectivity before starting server
	if (!pixie::db::test_connection(conn_str)) {
		std::cerr << "Could not connect to PostgreSQL.\n";
		return 1;
	}

	std::cout << "Connected to database successfully.\n";

	// register all routes
	pixie::routes::register_ping(app);
	pixie::routes::register_dbtest(app, conn_str);

	std::cout << "Server running on http://localhost:18080\n";

	// launch server
	app.port(18080).multithreaded().run();

}