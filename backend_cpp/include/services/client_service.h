// include/services/client_service.h
#pragma once

#include <string>
#include <optional>
#include <vector>
#include "dto/client_dto.h"

namespace pixie::services {

    struct ClientRecord {
        std::string id;
        std::string first_name;
        std::string last_name;
        std::optional<std::string> dob;
        std::string created_at;
    };

    ClientRecord create_client(const pixie::dto::ClientCreateDTO& input);
    std::vector<ClientRecord> get_all_clients();

}

