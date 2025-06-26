// src/dto/validation.cpp

#include "dto/validation.h"
#include "error-handling/error.h"

namespace pixie::dto::validation {

    bool is_valid_email(const std::string& email) {
        const std::regex pattern(R"(^[^@\s]+@[^@\s]+\.[^@\s]+$)");
        return std::regex_match(email, pattern);
    }

    bool is_valid_iso_date(const std::string& date) {
        const std::regex iso(R"(^\d{4}-\d{2}-\d{2}$)");
        return std::regex_match(date, iso);
    }

    bool is_in_set(const std::string& value, const std::vector<std::string>& allowed) {
        return std::find(allowed.begin(), allowed.end(), value) != allowed.end();
    }

    void require_field(const nlohmann::json& j, const std::string& field) {
        if (!j.contains(field) || j[field].is_null()) {
            throw pixie::error::ValidationError("Missing required field: " + field);
        }
    }

}
