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

DOCKER_PATH ?= $(PROJECT_ROOT)/docker
PRISMA ?= $(YARN) prisma
PRISMA_DATABASE_ENGINE ?= sqlite
PSQL ?= psql
TSUP ?= $(YARN) tsup

export POSTGRES_URL ?= \
	postgresql://$(POSTGRES_PASSWORD):$(POSTGRES_USER)@$(POSTGRES_HOST):$(POSTGRES_PORT)/$(POSTGRES_DATABASE)?sslmode=prefer
WAIT_FOR_POSTGRES ?= $(ECHO) 'waiting for postgres...' && \
	until $(PSQL) "$(POSTGRES_URL)" -c '\q' && break; do sleep 1; done; sleep 1 && echo "postgres ready"

.PHONY: deploy
deploy: $(PRISMA_DATABASE_ENGINE) ##
ifneq ($(PRISMA_DATABASE_ENGINE),none)
	@$(PRISMA) migrate deploy $(DEPLOY_ARGS)
endif
ifeq ($(PRISMA_SEED),1)
	@$(MKPM_MAKE) seed
endif

.PHONY: dev
dev: $(PRISMA_DATABASE_ENGINE) ##
ifneq ($(PRISMA_DATABASE_ENGINE),none)
	@$(ECHO) | $(PRISMA) migrate dev $(DEV_ARGS)
endif
ifeq ($(PRISMA_SEED),1)
	@$(MKPM_MAKE) seed
endif

.PHONY: reset
reset: $(PRISMA_DATABASE_ENGINE) ##
	@$(ECHO) | $(PRISMA) migrate reset $(RESET_ARGS)

.PHONY: squash
squash: ##
	@$(RM) -rf migrations $(NOFAIL)
	@$(MKPM_MAKE) reset
	@$(MKPM_MAKE) dev

.PHONY: pull
pull: $(PRISMA_DATABASE_ENGINE) ##
	@$(PRISMA) db pull $(PULL_ARGS)

.PHONY: push
push: $(PRISMA_DATABASE_ENGINE) ##
	@$(PRISMA) db push $(PUSH_ARGS)

.PHONY: format
format: ##
	@$(PRISMA) format $(FORMAT_ARGS)

.PHONY: studio
studio: $(PRISMA_DATABASE_ENGINE) ##
	@$(PRISMA) studio -p $(PRISMA_STUDIO_PORT) $(STUDIO_ARGS)

.PHONY: generate
generate: ##
	@$(PRISMA) generate $(GENERATE_ARGS)

.PHONY: seed seed@build
seed: dist/seed.js $(PRISMA_DATABASE_ENGINE) ##
	@$(PRISMA) db seed $(SEED_ARGS)
seed@build: dist/seed.js
dist/seed.js: seed.ts ../package.json
	@$(TSUP)

.PHONY: postgres sqlite
postgres:
	@$(MKPM_MAKE) -C $(DOCKER_PATH) postgres-d
	@$(WAIT_FOR_POSTGRES)
sqlite: ##

.PHONY: none
none:
	@$(ECHO) NO DATABASE ENGINE
