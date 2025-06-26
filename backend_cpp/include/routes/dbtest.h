// include/routes/dbtest.h

#pragma once
#include <crow.h>

namespace pixie::routes {
	// register /dbtest endpoint
	void register_dbtest(crow::SimpleApp& app, const std::string& conn_str);
}