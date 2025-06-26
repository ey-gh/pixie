// src/core/logger.cpp

#include "core/logger.h"
#include <mutex>
#include <fstream>
#include <filesystem>
#include <ctime>
#include <iomanip>
#include <sstream>

namespace pixie::core {

	static std::mutex log_mutex;

	std::string current_timestamp() {
		std::time_t now = std::time(nullptr);
		std::tm tm_buf;
#ifdef _WIN32
		localtime_s(&tm_buf, &now);
#else
		localtime_r(&now, &tm_buf);
#endif
		std::ostringstream oss;
		oss << std::put_time(&tm_buf, "%Y-%m-%d %H:%M:%S");
		return oss.str();
	}

	void log_message(LogLevel level, const std::string& message) {
		std::filesystem::create_directories("logs");

		std::lock_guard<std::mutex> lock(log_mutex);
		std::ofstream log_file("logs/errors.log", std::ios::app);

		std::string level_str;
		switch (level) {
		case LogLevel::INFO: level_str = "INFO"; break;
		case LogLevel::ERROR_: level_str = "ERROR"; break;
		case LogLevel::WARN: level_str = "WARN"; break;
		case LogLevel::DEBUG: level_str = "DEBUG"; break;
		}

		log_file << "[" << current_timestamp() << "] [" << level_str << "] " << message << std::endl;
	}

	void log_info(const std::string& message) { log_message(LogLevel::INFO, message); }
	void log_error(const std::string& message) { log_message(LogLevel::ERROR_, message); }
	void log_warn(const std::string& message) { log_message(LogLevel::WARN, message); }
	void log_debug(const std::string& message) { log_message(LogLevel::DEBUG, message); }

}
