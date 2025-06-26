// include/middleware/request_logger.h

#pragma once

#include <crow.h>
#include <string>
#include <chrono>

namespace pixie::middleware {

    struct RequestLogger {
        struct context {
            std::string request_id;
            std::chrono::steady_clock::time_point start_time;
        };

        RequestLogger();

        void before_handle(crow::request& req, crow::response& res, context& ctx);
        void after_handle(crow::request& req, crow::response& res, context& ctx);
    };

} // namespace pixie::middleware
