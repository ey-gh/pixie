// src/util/env_loader.cpp

#include "util/env_loader.h"
#include <fstream>
#include <stdexcept>
#include <filesystem>
#include <sstream>
#include <algorithm>
#include <mutex>
#include <iostream>

#ifdef _WIN32
#include <Windows.h>
#else
#include <limits.h>
#include <unistd.h>
#endif

namespace pixie::util {

    // Get the directory of the current executable
    std::string get_executable_dir() {
#ifdef _WIN32
        char buffer[MAX_PATH];
        GetModuleFileNameA(NULL, buffer, MAX_PATH);
        return std::filesystem::path(buffer).parent_path().string();
#else
        char result[PATH_MAX];
        ssize_t count = readlink("/proc/self/exe", result, PATH_MAX);
        return std::filesystem::path(std::string(result, count)).parent_path().string();
#endif
    }

    // Trim whitespace from both ends of a string (in-place)
    static inline void trim(std::string& s) {
        s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](unsigned char ch) {
            return !std::isspace(ch);
            }));
        s.erase(std::find_if(s.rbegin(), s.rend(), [](unsigned char ch) {
            return !std::isspace(ch);
            }).base(), s.end());
    }

    // Static environment cache + mutex for multi-suffix support
    static std::map<std::string, std::map<std::string, std::string>> env_cache;
    static std::mutex env_mutex;

    const std::map<std::string, std::string>& load_env(const std::string& suffix) {
        std::lock_guard<std::mutex> lock(env_mutex);

        // Return cached version if already loaded
        auto it = env_cache.find(suffix);
        if (it != env_cache.end()) {
            return it->second;
        }

        std::filesystem::path dir = get_executable_dir();
        const std::string filename = ".env." + suffix;

        while (!dir.empty()) {
            std::filesystem::path candidate = dir / filename;
            if (std::filesystem::exists(candidate)) {
                std::ifstream file(candidate);
                if (!file) {
                    throw std::runtime_error("Failed to open " + candidate.string());
                }

                std::map<std::string, std::string> env_vars;
                std::string line;
                size_t line_number = 0;

                while (std::getline(file, line)) {
                    line_number++;
                    trim(line);
                    if (line.empty() || line[0] == '#') continue;

                    auto sep = line.find('=');
                    if (sep == std::string::npos) {
                        std::cerr << "[env_loader] Skipping malformed line " << line_number << ": " << line << "\n";
                        continue;
                    }

                    std::string key = line.substr(0, sep);
                    std::string value = line.substr(sep + 1);
                    trim(key);
                    trim(value);

                    // Remove surrounding quotes if present
                    if (!value.empty() && value.front() == '"' && value.back() == '"') {
                        value = value.substr(1, value.size() - 2);
                    }

                    env_vars[key] = value;
                }

                std::cout << "[env_loader] Loaded " << env_vars.size()
                    << " variable(s) from " << candidate.string() << "\n";

                // Cache and return
                env_cache[suffix] = std::move(env_vars);
                return env_cache[suffix];
            }

            dir = dir.parent_path();
        }

        throw std::runtime_error("Environment file " + filename + " not found in any parent directories");
    }

    std::string get_env_value(const std::string& key, const std::string& suffix) {
        const auto& env = load_env(suffix);
        auto it = env.find(key);
        if (it == env.end()) {
            throw std::runtime_error("Environment variable not found: " + key);
        }
        return it->second;
    }
}