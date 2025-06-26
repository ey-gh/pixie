// include/validators/validation_utils.h

#pragma once

#include <string>
#include <vector>

namespace pixie::validators {

	bool is_valid_email(const std::string& email);
	bool is_valid_iso_date(const std::string& date);
	bool is_in_set(const std::string& value, const std::vector<std::string>& allowed);

}
