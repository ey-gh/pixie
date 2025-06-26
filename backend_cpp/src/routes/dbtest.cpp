// src/routes/dbtest.cpp

#include "routes/dbtest.h"
#include <pqxx/pqxx>

namespace pixie::routes {
	void register_dbtest(crow::SimpleApp& app, const std::string& conn_str) {
		// GET
		CROW_ROUTE(app, "/dbtest").methods(crow::HTTPMethod::GET)([conn_str]() {
			try {
				pqxx::connection conn(conn_str);
				pqxx::work txn(conn);

				// query
				pqxx::result r = txn.exec("SELECT version();");
				txn.commit();

				// response
				std::string version = r[0][0].as<std::string>();
				return crow::response(200, "PostgreSQL version: " + version);
			}
			catch (const std::exception& e) {
				return crow::response(500, std::string("DB error: ") + e.what());
			}
		});
	}
}