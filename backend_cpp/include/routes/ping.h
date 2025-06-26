// include/routes/ping.h

#pragma once
#include <crow.h>

namespace pixie::routes {
	// registers a basic health check route at /ping
	void register_ping(crow::SimpleApp& app);
}