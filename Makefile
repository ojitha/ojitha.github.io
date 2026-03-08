.DEFAULT_GOAL := all

# Variables
DRAFTS_DIR = ./_posts
ASSETS_DIR = ./assets/images

md_targets :=
asset_targets :=

# Markdown copy rule
define md-copy
$(DRAFTS_DIR)/$1.md : $2/$1.md | $(DRAFTS_DIR)
	@echo "-------------------------"
	@echo "copy $$< -> $$@"
	cp $$< $$@
	@echo "-------------------------"
endef

# Assets copy rule
define assets-copy
$(ASSETS_DIR)/$1:
	@echo "Checking for assets folder $1..."
	@if [ -d "$2/assets/images/$1" ]; then \
		echo "Assets folder exists, copying..."; \
		mkdir -p $(ASSETS_DIR)/$1; \
		cp -r $2/assets/images/$1/* $(ASSETS_DIR)/$1/; \
		echo "Assets copied to $(ASSETS_DIR)/$1"; \
	else \
		echo "No assets folder found for $1, creating empty directory..."; \
		mkdir -p $(ASSETS_DIR)/$1; \
	fi
endef

# Include per-section blog definitions
# include makefiles/scala2.mk
# include makefiles/spark.mk
# include makefiles/bedrock.mk
# include makefiles/k8s.mk
include makefiles/llmtuning.mk

# All target
all: $(md_targets) $(asset_targets)

# Directory creation rule
$(DRAFTS_DIR):
	@echo "Creating drafts directory..."
	mkdir -p $(DRAFTS_DIR)

.PHONY: all
