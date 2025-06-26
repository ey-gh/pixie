// include/core/pg_pool.h

#pragma once
#include <memory>
#include <string>
#include <mutex>
#include <vector>

namespace pqxx {
	class connection;
}

namespace pixie::core {

	class PgPool {
	public:
		PgPool(const std::string& conn_str, size_t size);
		std::shared_ptr<pqxx::connection> acquire();

	private:
		std::vector<std::shared_ptr<pqxx::connection>> pool;
		std::mutex pool_mutex;
		size_t next = 0;
	};

	// Singleton lifecycle
	PgPool& get_pg_pool();
	void init_pg_pool(const std::string& conn_str, size_t size);

}
