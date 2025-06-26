// src/util/env_loader.cpp

#include "util/env_loader.h"
#include <fstream>
#include <stdexcept>

namespace pixie::util {

	std::string load_connection_string(const std::string& path) {
		std::ifstream file(path);
		if (!file) throw std::runtime_error(".env file not found");

		std::string line;
		while (std::getline(file, line)) {
			// match line starting with PG_CONN_STRING=
			if (line.find("PG_CONN_STRING=") == 0) {
				// extract connection string by removing prefix (15 chars)
				return line.substr(15);
			}
		}

		throw std::runtime_error("PG_CONN_STRING not found in .env");
	}
}