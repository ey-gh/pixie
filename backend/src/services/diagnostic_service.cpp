// src/services/diagnostic_service.cpp

#include "services/diagnostic_service.h"
#include "core/pg_pool.h"

#include <pqxx/pqxx>

namespace pixie::services {

	std::string get_postgres_version() {
		auto& pool = pixie::core::get_pg_pool();
		auto conn = pool.acquire();
		pqxx::work txn(*conn);

		auto result = txn.exec("SELECT version();");
		txn.commit();

		return result[0][0].c_str();
	}

	std::string get_health_ping() {
		return "pong";
	}
}
