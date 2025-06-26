// include/util/env_loader.h

#pragma once
#include <string>
#include <map>

namespace pixie::util {
	// get a single env variable by key and suffix (e.g., .env.backend)
	std::string get_env_value(const std::string& key, const std::string& suffix = "backend");

	// get full pasred env map for a given suffix
	const std::map<std::string, std::string>& load_env(const std::string& suffix = "backend");
}