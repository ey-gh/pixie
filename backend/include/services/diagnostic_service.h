// include/services/diagnostic_service.h
#pragma once
#include <string>

namespace pixie::services {
	std::string get_postgres_version();
	std::string get_health_ping();
}
