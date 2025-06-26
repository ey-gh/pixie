// include/db/connection.h

#pragma once
#include <string>

namespace pixie::db {
	// attempts a simple PostgreSQL connection test (SELECT 1)
	// returns TRUE if successful, FALSE otherwise
	bool test_connection(const std::string& conn_str);
}