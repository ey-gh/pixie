// include/dto/validation.h

#pragma once

#include <string>
#include <vector>
#include <regex>
#include <nlohmann/json.hpp>

namespace pixie::dto::validation {

	bool is_valid_email(const std::string& email);
	bool is_valid_iso_date(const std::string& date);
	bool is_in_set(const std::string& value, const std::vector<std::string>& allowed);

	void require_field(const nlohmann::json& j, const std::string& field);

}
