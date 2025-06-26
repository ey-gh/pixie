// src/error-handling/error.cpp

#include "error-handling/error.h"
#include "core/logger.h"
#include <nlohmann/json.hpp>

using json = nlohmann::json;

namespace pixie::error {

    crow::response BaseError::to_response() const {
        pixie::core::log_error("[error] " + get_log_detail());

        json json_resp = {
            {"error", message}
        };

        crow::response resp{ status_code };
        resp.set_header("Content-Type", "application/json");
        resp.body = json_resp.dump();  // Now supported!
        return resp;
    }

} // namespace pixie::error
