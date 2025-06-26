// src/core/pg_pool.cpp

#include "core/pg_pool.h"
#include "core/logger.h"

#include <pqxx/pqxx>
#include <mutex>
#include <vector>
#include <memory>

namespace pixie::core {

	static std::unique_ptr<PgPool> pool_instance;

	PgPool::PgPool(const std::string& conn_str, size_t size) {
		for (size_t i = 0; i < size; ++i) {
			auto conn = std::make_shared<pqxx::connection>(conn_str);

			// Safe to call multiple times with same name & SQL
			conn->prepare("insert_client",
				"INSERT INTO clients (first_name, last_name, dob, email) "
				"VALUES ($1, $2, $3, $4) RETURNING id, created_at");

			pool.emplace_back(std::move(conn));
		}
		log_info("PgPool initialized with " + std::to_string(size) + " connections.");
	}

	std::shared_ptr<pqxx::connection> PgPool::acquire() {
		std::lock_guard<std::mutex> lock(pool_mutex);
		auto conn = pool[next];
		next = (next + 1) % pool.size();
		return conn;
	}

	PgPool& get_pg_pool() {
		if (!pool_instance) {
			throw std::runtime_error("PgPool not initialized. Call init_pg_pool() first.");
		}
		return *pool_instance;
	}

	void init_pg_pool(const std::string& conn_str, size_t size) {
		if (!pool_instance) {
			pool_instance = std::make_unique<PgPool>(conn_str, size);
		}
	}

}
