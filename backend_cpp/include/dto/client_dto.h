// include/dto/client_dto.h

#pragma once

#include <string>
#include <optional>
#include <nlohmann/json.hpp>

namespace pixie::dto {

    struct ClientCreateDTO {
        std::string first_name;
        std::string last_name;
        std::string dob;
        std::optional<std::string> email;
        std::optional<std::string> phone;
        std::optional<std::string> gender;

        static ClientCreateDTO from_json(const nlohmann::json& j);
    };

}
