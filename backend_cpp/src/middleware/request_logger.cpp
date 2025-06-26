// src/middleware/request_logger.cpp

#include "middleware/request_logger.h"
#include "core/logger.h"
#include "error-handling/error.h"

#include <random>
#include <sstream>

namespace pixie::middleware {

    // Max request body size (1 MB)
    constexpr size_t MAX_BODY_SIZE = 1024 * 1024;

    // Generate a simple UUID v4 (not cryptographically secure)
    std::string generate_uuid_v4() {
        static std::random_device rd;
        static std::mt19937 gen(rd());
        static std::uniform_int_distribution<> dis(0, 15);
        static const char* hex = "0123456789abcdef";

        std::stringstream ss;
        for (int i = 0; i < 32; ++i) {
            ss << hex[dis(gen)];
            if (i == 7 || i == 11 || i == 15 || i == 19) ss << '-';
        }
        return ss.str();
    }

    RequestLogger::RequestLogger() {}

    void RequestLogger::before_handle(crow::request& req, crow::response& res, context& ctx) {
        ctx.start_time = std::chrono::steady_clock::now();
        ctx.request_id = generate_uuid_v4();

        // Enforce max request size
        if (req.body.length() > MAX_BODY_SIZE) {
            res.code = 413; // Payload Too Large
            res.set_header("Content-Type", "application/json");
            res.body = R"({"error": "Payload too large"})";
            res.end();
            return;
        }

        std::string method = crow::method_name(req.method);
        pixie::core::log_info("[http] " + method + " " + req.raw_url + " [req_id=" + ctx.request_id + "]");

    }

    void RequestLogger::after_handle(crow::request& /*req*/, crow::response& res, context& ctx) {
        res.set_header("X-Request-ID", ctx.request_id);
        res.set_header("X-Powered-By", "Pixie");
    }

} // namespace pixie::middleware
