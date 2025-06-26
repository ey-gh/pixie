// src/routes/ping.cpp

#include "routes/ping.h"

namespace pixie::routes {

	void register_ping(crow::SimpleApp& app) {
		// simple health endpoint: responds with "pong"
		CROW_ROUTE(app, "/ping")([] {
			return crow::response("pong");
			});
	}
}
