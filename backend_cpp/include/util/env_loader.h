// include/util/env_loader.h

#pragma once
#include <string>

namespace pixie::util {
	// loads PG connection string from .env file
	// throws if .env is missing or misformatted
	std::string load_connection_string(const std::string& path = ".env");
}