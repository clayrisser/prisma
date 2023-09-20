# File: /main.mk
# Project: prisma
# File Created: 18-09-2023 11:59:01
# Author: Clay Risser
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

NODE_MODULES_BIN ?= $(PROJECT_ROOT)/node_modules/.bin
PRISMA ?= $(call yarn_binary,prisma)
PRISMA_DATABASE_ENGINE ?= sqlite
TSUP ?= $(call yarn_binary,tsup)
WAIT_FOR_POSTGRES ?= $(call yarn_binary,wait-for-postgres)

.PHONY: deploy
deploy: $(PRISMA_DATABASE_ENGINE) ##
ifneq ($(PRISMA_DATABASE_ENGINE),none)
	@$(EXPORT) PATH="$(NODE_MODULES_BIN):$(PATH)" && \
		$(PRISMA) migrate deploy $(DEPLOY_ARGS)
endif
ifeq ($(PRISMA_SEED),1)
	@$(MAKE) -s seed
endif

.PHONY: dev
dev: $(PRISMA_DATABASE_ENGINE) ##
ifneq ($(PRISMA_DATABASE_ENGINE),none)
	@$(EXPORT) PATH="$(NODE_MODULES_BIN):$(PATH)" && \
		$(ECHO) | $(PRISMA) migrate dev $(DEV_ARGS)
endif
ifeq ($(PRISMA_SEED),1)
	@$(MAKE) -s seed
endif

.PHONY: reset
reset: $(PRISMA_DATABASE_ENGINE) ##
	@$(EXPORT) PATH="$(NODE_MODULES_BIN):$(PATH)" && \
		$(ECHO) | $(PRISMA) migrate reset $(RESET_ARGS)

.PHONY: squash
squash: ##
	@$(RM) -rf migrations $(NOFAIL)
	@$(MAKE) -s reset
	@$(MAKE) -s dev

.PHONY: pull
pull: $(PRISMA_DATABASE_ENGINE) ##
	@export PATH="$(NODE_MODULES_BIN):$(PATH)" && \
		$(PRISMA) db pull $(PULL_ARGS)

.PHONY: push
push: $(PRISMA_DATABASE_ENGINE) ##
	@export PATH="$(NODE_MODULES_BIN):$(PATH)" && \
		$(PRISMA) db push $(PUSH_ARGS)

.PHONY: format
format: ##
	@export PATH="$(NODE_MODULES_BIN):$(PATH)" && \
		$(PRISMA) format $(FORMAT_ARGS)

.PHONY: studio
studio: $(PRISMA_DATABASE_ENGINE) ##
	@export PATH="$(NODE_MODULES_BIN):$(PATH)" && \
		$(PRISMA) studio -p $(PRISMA_STUDIO_PORT) $(STUDIO_ARGS)

.PHONY: generate
generate: ##
	@export PATH="$(NODE_MODULES_BIN):$(PATH)" && \
		$(PRISMA) generate $(GENERATE_ARGS)

.PHONY: seed seed@build
seed: dist/seed.js $(PRISMA_DATABASE_ENGINE) ##
	@export PATH="$(NODE_MODULES_BIN):$(PATH)" && \
		$(PRISMA) db seed $(SEED_ARGS)
seed@build: dist/seed.js
dist/seed.js: seed.ts ../package.json
	@$(TSUP)

.PHONY: postgres sqlite
postgres:
	@$(MAKE) -s -C ../docker postgres-d
	@$(WAIT_FOR_POSTGRES)
sqlite: ##

.PHONY: none
none:
	@$(ECHO) NO DATABASE ENGINE

CACHE_ENVS += \
	PRISMA \
	TSUP \
	WAIT_FOR_POSTGRES
