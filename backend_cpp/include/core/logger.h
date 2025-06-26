// include/core/logger.h

#pragma once
#include <string>

namespace pixie::core {

	enum class LogLevel {
		INFO,
		ERROR_,
		WARN,
		DEBUG
	};

	// Global logger API
	void log_message(LogLevel level, const std::string& message);
	void log_info(const std::string& message);
	void log_error(const std::string& message);
	void log_warn(const std::string& message);
	void log_debug(const std::string& message);
}
