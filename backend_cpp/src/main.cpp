// src/main.cpp

#include "core/app.h"
#include "core/logger.h"

int main() {
	try {
		return pixie::core::run_backend();  // Single call, entry point
	}
	catch (const std::exception& e) {
		pixie::core::log_error(std::string("[main] Fatal: ") + e.what());
		return 1;
	}
}
