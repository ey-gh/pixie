// src/dto/client_dto.cpp

#include "dto/client_dto.h"
#include "validators/validation_utils.h"
#include "error-handling/error.h"

using pixie::error::ValidationError;

namespace pixie::dto {

    ClientCreateDTO ClientCreateDTO::from_json(const nlohmann::json& j) {
        // Required fields
        if (!j.contains("first_name") || !j["first_name"].is_string() || j["first_name"].get<std::string>().empty()) {
            throw ValidationError("first_name is required and must be a non-empty string");
        }
        if (!j.contains("last_name") || !j["last_name"].is_string() || j["last_name"].get<std::string>().empty()) {
            throw ValidationError("last_name is required and must be a non-empty string");
        }
        if (!j.contains("dob") || !j["dob"].is_string() || !pixie::validators::is_valid_iso_date(j["dob"])) {
            throw ValidationError("dob is required and must be in YYYY-MM-DD format");
        }

        ClientCreateDTO dto;
        dto.first_name = j["first_name"];
        dto.last_name = j["last_name"];
        dto.dob = j["dob"];

        // Optional fields
        if (j.contains("email")) {
            if (!j["email"].is_string() || !pixie::validators::is_valid_email(j["email"])) {
                throw ValidationError("email must be a valid email address");
            }
            dto.email = j["email"];
        }

        if (j.contains("phone") && j["phone"].is_string()) {
            dto.phone = j["phone"];
        }

        if (j.contains("gender")) {
            std::string gender = j["gender"];
            if (!pixie::validators::is_in_set(gender, { "male", "female", "other", "undisclosed" })) {
                throw ValidationError("gender must be one of: male, female, other, undisclosed");
            }
            dto.gender = gender;
        }

        return dto;
    }

}

