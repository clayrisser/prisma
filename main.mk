# File: /main.mk
# Project: mkpm-prisma
# File Created: 06-05-2022 03:17:23
# Author: Clay Risser
# -----
# Last Modified: 04-11-2022 08:20:03
# Modified By: Clay Risser
# -----
# Risser Labs LLC (c) Copyright 2021 - 2022
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

BABEL_NODE ?= $(call yarn_binary,babel-node)
DATABASE_ENGINE ?= sqlite
NODE_MODULES_BIN ?= $(PROJECT_ROOT)/node_modules/.bin
PRISMA ?= $(call yarn_binary,prisma)
WAIT_FOR_POSTGRES ?= $(call yarn_binary,wait-for-postgres)

.PHONY: deploy
deploy: $(DATABASE_ENGINE) ##
ifneq ($(DATABASE_ENGINE),none)
	@$(EXPORT) PATH="$(NODE_MODULES_BIN):$(PATH)" && \
		$(PRISMA) migrate deploy $(ARGS)
	@$(MAKE) -s seed
endif

.PHONY: dev
dev: $(DATABASE_ENGINE) deploy ##
ifneq ($(DATABASE_ENGINE),none)
	@$(EXPORT) PATH="$(NODE_MODULES_BIN):$(PATH)" && \
		$(ECHO) | $(PRISMA) migrate dev --skip-generate $(ARGS)
endif

.PHONY: reset
reset: $(DATABASE_ENGINE) ##
	@$(EXPORT) PATH="$(NODE_MODULES_BIN):$(PATH)" && \
		$(ECHO) | $(PRISMA) migrate reset $(ARGS)

.PHONY: squash
squash: ##
	@$(RM) -rf migrations $(NOFAIL)
	@$(MAKE) -s reset
	@$(MAKE) -s dev

.PHONY: pull
pull: $(DATABASE_ENGINE) ##
	@$(PRISMA) db pull

.PHONY: push
push: $(DATABASE_ENGINE) ##
	@$(PRISMA) db push

.PHONY: format
format: ##
	@$(PRISMA) format

.PHONY: studio
studio: $(DATABASE_ENGINE) ##
	@$(PRISMA) studio $(ARGS)

.PHONY: generate
generate: ##
	@$(PRISMA) generate $(ARGS)

.PHONY: seed +seed
seed: $(DATABASE_ENGINE) ##
	@export PATH="$(NODE_MODULES_BIN):$(PATH)" && \
		$(PRISMA) db seed $(ARGS)
+seed: $(PROJECT_ROOT)/dist/seed.js
	@$(CD) $(PROJECT_ROOT) && $(NODE) $(PROJECT_ROOT)/dist/seed.js
$(PROJECT_ROOT)/dist/seed.js: $(PROJECT_ROOT)/prisma/seed.ts $(PROJECT_ROOT)/package.json
	@$(CD) $(PROJECT_ROOT) && $(WEBPACK) --output-filename seed.js $<

.PHONY: postgres sqlite
postgres:
	@$(MAKE) -s -C ../docker postgres-d
	@$(WAIT_FOR_POSTGRES)
sqlite: ##

.PHONY: none
none:
	@$(ECHO) NO DATABASE ENGINE
