// include/routes/clients.h
#pragma once
#include <crow.h>

namespace pixie::routes {
	void register_client_routes(crow::SimpleApp& app);
}
