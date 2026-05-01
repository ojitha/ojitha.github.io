.DEFAULT_GOAL := all

VENV := ../notebooks/jupyter/.venv
export PATH := $(abspath $(VENV))/bin:$(PATH)

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

# $(call register-section,SOURCE_DIR,STEMS)
define register-section
md_targets    += $$(foreach s,$2,$$(DRAFTS_DIR)/$$(s).md)
asset_targets += $$(foreach s,$2,$$(ASSETS_DIR)/$$(s))
$$(foreach s,$2,$$(eval $$(call md-copy,$$(s),$1)))
$$(foreach s,$2,$$(eval $$(call assets-copy,$$(s),$1)))

# Build the source .md from its .ipynb via the sibling repo's Makefile
$1/%.md: $1/%.ipynb
	$$(MAKE) -C $1 $$*.md
endef

# Default: include everything. Override with `make SECTION=scala2`
SECTION ?= all

ifeq ($(SECTION),all)
  include $(wildcard makefiles/*.mk)
else
  include makefiles/$(SECTION).mk
endif

# All target
all: $(md_targets) $(asset_targets)

# Directory creation rule
$(DRAFTS_DIR):
	@echo "Creating drafts directory..."
	mkdir -p $(DRAFTS_DIR)

.PHONY: all
