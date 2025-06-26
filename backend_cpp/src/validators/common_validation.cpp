// src/validators/common_validations.cpp

#include "validators/common_validation.h"
#include <regex>

namespace pixie::validators {

	bool is_valid_email(const std::string& email) {
		return email.find('@') != std::string::npos && email.find('.') != std::string::npos;
	}

	bool is_valid_date(const std::string& date) {
		static const std::regex pattern(R"(^\d{4}-\d{2}-\d{2}$)");
		return std::regex_match(date, pattern);
	}

}
