# File: /Makefile
# Project: prisma
# File Created: 03-08-2023 18:03:28
# Author: Ajith Kumar
# -----
# Last Modified: 18-09-2023 13:00:30
# Modified By: Clay Risser
# -----
# BitSpur (c) Copyright 2021 - 2023
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

.ONESHELL:
.POSIX:
.SILENT:

MKPM := ./mkpm
.PHONY: %
%:
	@$(MKPM) "$@" $(ARGS)
