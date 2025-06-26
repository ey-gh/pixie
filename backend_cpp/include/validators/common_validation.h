// include/validators/common_validation.h

#pragma once
#include <string>

namespace pixie::validators {
	bool is_valid_email(const std::string& email);
	bool is_valid_date(const std::string& date);
}
