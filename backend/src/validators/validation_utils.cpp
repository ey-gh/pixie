// src/validators/validation_utils.cpp

#include "validators/validation_utils.h"
#include <regex>
#include <algorithm>

namespace pixie::validators {

    bool is_valid_email(const std::string& email) {
        static const std::regex pattern(R"(^[^@\s]+@[^@\s]+\.[^@\s]+$)");
        return std::regex_match(email, pattern);
    }

    bool is_valid_iso_date(const std::string& date) {
        static const std::regex pattern(R"(^\d{4}-\d{2}-\d{2}$)");
        return std::regex_match(date, pattern);
    }

    bool is_in_set(const std::string& value, const std::vector<std::string>& allowed) {
        return std::find(allowed.begin(), allowed.end(), value) != allowed.end();
    }

}
