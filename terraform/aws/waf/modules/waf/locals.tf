# Copyright (C) 2021 Nicolas Lamirault <nicolas.lamirault@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

locals {
  acl_core_name               = format("%s-core", var.service_name)
  acl_custom_name             = format("%s-custom", var.service_name)
  acl_whitelist_name          = format("%s-whitelist", var.service_name)
  acl_blacklist_name          = format("%s-blacklist", var.service_name)
  rule_whitelist_country_name = format("%s-WhitelistByCountry", var.service_name)
  rule_whitelist_ips          = format("%s-WhitelistByCIDRs", var.service_name)
  rule_blacklist_ips          = format("%s-BlacklistByCIDRs", var.service_name)

  managed_rules = [
    { name = "AWSManagedRulesAmazonIpReputationList", priority = 1 },
    { name = "AWSManagedRulesCommonRuleSet", priority = 2 },
    { name = "AWSManagedRulesKnownBadInputsRuleSet", priority = 3 },
    { name = "AWSManagedRulesLinuxRuleSet", priority = 4 },
    { name = "AWSManagedRulesAnonymousIpList", priority = 5 },
    { name = "AWSManagedRulesBotControlRuleSet", priority = 6 }
    # { name = "AWSManagedRulesUnixRuleSet", priority = 7 },
    # { name = "AWSManagedRulesAdminProtectionRuleSet", priority = 1 },
    # { name = "AWSManagedRulesSQLiRuleSet", priority = 3 },
  ]
}