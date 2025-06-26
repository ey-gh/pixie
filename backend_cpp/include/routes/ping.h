// include/routes/ping.h
#pragma once
#include <crow.h>

namespace pixie::routes {
	void register_ping(crow::SimpleApp& app);
}
