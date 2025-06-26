// src/services/client_service.cpp

#include "services/client_service.h"
#include "core/pg_pool.h"
#include "core/logger.h"

#include <pqxx/pqxx>

namespace pixie::services {

	ClientRecord create_client(const pixie::validators::ClientInput& input) {
		auto& pool = pixie::core::get_pg_pool();
		auto conn = pool.acquire();
		pqxx::work txn(*conn);

		auto result = txn.exec_prepared("insert_client",
			input.first_name,
			input.last_name,
			input.dob.has_value() ? input.dob.value() : nullptr,
			input.email.has_value() ? input.email.value() : nullptr
		);

		txn.commit();

		ClientRecord record;
		record.id = result[0]["id"].c_str();
		record.created_at = result[0]["created_at"].c_str();

		return record;
	}

	std::vector<ClientRecord> get_all_clients() {
		auto& pool = pixie::core::get_pg_pool();
		auto conn = pool.acquire();
		pqxx::work txn(*conn);

		auto res = txn.exec("SELECT id, first_name, last_name, dob FROM clients WHERE is_active = TRUE");

		std::vector<ClientRecord> clients;
		for (const auto& row : res) {
			ClientRecord client;
			client.id = row["id"].c_str();
			client.first_name = row["first_name"].c_str();
			client.last_name = row["last_name"].c_str();
			if (!row["dob"].is_null()) {
				client.dob = row["dob"].c_str();
			}
			clients.push_back(std::move(client));
		}

		txn.commit();
		return clients;
	}

}
