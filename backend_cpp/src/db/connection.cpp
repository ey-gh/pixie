// src/db/connection.cpp

#include "db/connection.h"
#include <pqxx/pqxx>
#include <iostream>

namespace pixie::db {
	bool test_connection(const std::string& conn_str) {
		try {
			// open db connection
			pqxx::connection conn(conn_str);
			pqxx::work txn(conn);
			txn.exec("SELECT 1;");
			txn.commit();
			return true;
		}
		catch (const std::exception& e) {
			std::cerr << "DB error: " << e.what() << std::endl;
			return false;
		}
	}
}