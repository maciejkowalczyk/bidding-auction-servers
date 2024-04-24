//  Copyright 2022 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#ifndef FLEDGE_SERVICES_SELLER_FRONTEND_SERVICE_RUNTIME_FLAGS_H_
#define FLEDGE_SERVICES_SELLER_FRONTEND_SERVICE_RUNTIME_FLAGS_H_

#include <vector>

#include "absl/strings/string_view.h"
#include "services/common/constants/common_service_flags.h"

namespace privacy_sandbox::bidding_auction_servers {

// Define runtime flag names.
inline constexpr char PORT[] = "SELLER_FRONTEND_PORT";
inline constexpr char HEALTHCHECK_PORT[] = "SELLER_FRONTEND_HEALTHCHECK_PORT";
inline constexpr char GET_BID_RPC_TIMEOUT_MS[] = "GET_BID_RPC_TIMEOUT_MS";
inline constexpr char KEY_VALUE_SIGNALS_FETCH_RPC_TIMEOUT_MS[] =
    "KEY_VALUE_SIGNALS_FETCH_RPC_TIMEOUT_MS";
inline constexpr char SCORE_ADS_RPC_TIMEOUT_MS[] = "SCORE_ADS_RPC_TIMEOUT_MS";
inline constexpr char SELLER_ORIGIN_DOMAIN[] = "SELLER_ORIGIN_DOMAIN";
inline constexpr char AUCTION_SERVER_HOST[] = "AUCTION_SERVER_HOST";
inline constexpr char KEY_VALUE_SIGNALS_HOST[] = "KEY_VALUE_SIGNALS_HOST";
inline constexpr char BUYER_SERVER_HOSTS[] = "BUYER_SERVER_HOSTS";
inline constexpr char ENABLE_BUYER_COMPRESSION[] = "ENABLE_BUYER_COMPRESSION";
inline constexpr char ENABLE_AUCTION_COMPRESSION[] =
    "ENABLE_AUCTION_COMPRESSION";
inline constexpr char ENABLE_SELLER_FRONTEND_BENCHMARKING[] =
    "ENABLE_SELLER_FRONTEND_BENCHMARKING";
inline constexpr char CREATE_NEW_EVENT_ENGINE[] = "CREATE_NEW_EVENT_ENGINE";
inline constexpr char SFE_INGRESS_TLS[] = "SFE_INGRESS_TLS";
inline constexpr char SFE_TLS_KEY[] = "SFE_TLS_KEY";
inline constexpr char SFE_TLS_CERT[] = "SFE_TLS_CERT";
inline constexpr char AUCTION_EGRESS_TLS[] = "AUCTION_EGRESS_TLS";
inline constexpr char BUYER_EGRESS_TLS[] = "BUYER_EGRESS_TLS";
inline constexpr char SFE_PUBLIC_KEYS_ENDPOINTS[] = "SFE_PUBLIC_KEYS_ENDPOINTS";
inline constexpr char SELLER_CLOUD_PLATFORMS_MAP[] =
    "SELLER_CLOUD_PLATFORMS_MAP";

inline constexpr absl::string_view kFlags[] = {
    PORT,
    HEALTHCHECK_PORT,
    GET_BID_RPC_TIMEOUT_MS,
    KEY_VALUE_SIGNALS_FETCH_RPC_TIMEOUT_MS,
    SCORE_ADS_RPC_TIMEOUT_MS,
    SELLER_ORIGIN_DOMAIN,
    AUCTION_SERVER_HOST,
    KEY_VALUE_SIGNALS_HOST,
    BUYER_SERVER_HOSTS,
    ENABLE_BUYER_COMPRESSION,
    ENABLE_AUCTION_COMPRESSION,
    ENABLE_SELLER_FRONTEND_BENCHMARKING,
    CREATE_NEW_EVENT_ENGINE,
    SFE_INGRESS_TLS,
    SFE_TLS_KEY,
    SFE_TLS_CERT,
    AUCTION_EGRESS_TLS,
    BUYER_EGRESS_TLS,
    SFE_PUBLIC_KEYS_ENDPOINTS,
    SELLER_CLOUD_PLATFORMS_MAP,
};

inline std::vector<absl::string_view> GetServiceFlags() {
  int size = sizeof(kFlags) / sizeof(kFlags[0]);
  std::vector<absl::string_view> flags(kFlags, kFlags + size);

  for (absl::string_view flag : kCommonServiceFlags) {
    flags.push_back(flag);
  }

  return flags;
}

}  // namespace privacy_sandbox::bidding_auction_servers

#endif  // FLEDGE_SERVICES_SELLER_FRONTEND_SERVICE_RUNTIME_FLAGS_H_
