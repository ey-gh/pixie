// include/error-handling/error.h

#pragma once

#include <string>
#include <exception>
#include <crow.h>

namespace pixie::error {

    class BaseError : public std::exception {
    public:
        BaseError(std::string msg, int code, std::string log = "")
            : message(std::move(msg)), status_code(code), log_detail(std::move(log)) {
        }

        const char* what() const noexcept override { return message.c_str(); }

        int get_status_code() const { return status_code; }
        std::string get_log_detail() const { return log_detail.empty() ? message : log_detail; }

        virtual crow::response to_response() const;

    protected:
        std::string message;
        int status_code;
        std::string log_detail;
    };

    class ValidationError : public BaseError {
    public:
        ValidationError(const std::string& msg, const std::string& log = "")
            : BaseError(msg, 400, log) {
        }
    };

    class DatabaseError : public BaseError {
    public:
        DatabaseError(const std::string& msg, const std::string& log = "")
            : BaseError(msg, 500, log) {
        }
    };

    class NotFoundError : public BaseError {
    public:
        NotFoundError(const std::string& msg, const std::string& log = "")
            : BaseError(msg, 404, log) {
        }
    };

    class InternalError : public BaseError {
    public:
        InternalError(const std::string& msg, const std::string& log = "")
            : BaseError(msg, 500, log) {
        }
    };

} // namespace pixie::error
