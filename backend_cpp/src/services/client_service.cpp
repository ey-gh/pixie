// src/services/client_service.cpp
#include "services/client_service.h"
#include "core/pg_pool.h"
#include "core/logger.h"
#include "error-handling/error.h"

#include <pqxx/pqxx>

using pixie::error::DatabaseError;

namespace pixie::services {

    ClientRecord create_client(const pixie::dto::ClientCreateDTO& input) {
        try {
            auto& pool = pixie::core::get_pg_pool();
            auto conn = pool.acquire();
            pqxx::work txn(*conn);

            auto result = txn.exec_params(
                R"(INSERT INTO clients (first_name, last_name, dob, email)
                VALUES ($1, $2, $3, $4)
                RETURNING id, created_at)",
                input.first_name,
                input.last_name,
                input.dob,
                input.email.value_or("")
            );

            txn.commit();

            ClientRecord record;
            record.id = result[0]["id"].c_str();
            record.first_name = input.first_name;
            record.last_name = input.last_name;
            record.dob = input.dob;
            record.created_at = result[0]["created_at"].c_str();

            return record;

        }
        catch (const std::exception& e) {
            throw DatabaseError("Failed to insert client", e.what());
        }
    }

    std::vector<ClientRecord> get_all_clients() {
        try {
            auto& pool = pixie::core::get_pg_pool();
            auto conn = pool.acquire();
            pqxx::work txn(*conn);

            auto res = txn.exec(R"(
            SELECT id, first_name, last_name, dob, created_at
            FROM clients
            WHERE is_active = TRUE
            ORDER BY created_at DESC
        )");

            std::vector<ClientRecord> clients;
            for (const auto& row : res) {
                ClientRecord client;
                client.id = row["id"].c_str();
                client.first_name = row["first_name"].c_str();
                client.last_name = row["last_name"].c_str();
                if (!row["dob"].is_null())
                    client.dob = row["dob"].c_str();
                client.created_at = row["created_at"].c_str();
                clients.push_back(std::move(client));
            }

            txn.commit();
            return clients;

        }
        catch (const std::exception& e) {
            throw DatabaseError("Failed to fetch clients", e.what());
        }
    }

}
