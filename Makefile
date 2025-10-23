# Variables
DRAFTS_DIR = ./_drafts
ASSETS_DIR = ./assets/images
Scala2BlogsDir := ../learn-scala2/blogs
Scala2BlogsSources := 2025-07-25-Scala-basics \
	2025-07-25-Scala-Collections 

# Create target file lists
md_targets := $(foreach wrd,$(Scala2BlogsSources),$(DRAFTS_DIR)/$(wrd).md)
asset_targets := $(foreach wrd,$(Scala2BlogsSources),$(ASSETS_DIR)/$(wrd))

all: $(md_targets) $(asset_targets)

# Directory creation rule
$(DRAFTS_DIR):
	@echo "Creating drafts directory..."
	mkdir -p $(DRAFTS_DIR)

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

# Generate the rules for Scala 2 posts
$(foreach element,$(Scala2BlogsSources),$(eval $(call md-copy,$(element),$(Scala2BlogsDir))))
$(foreach element,$(Scala2BlogsSources),$(eval $(call assets-copy,$(element),$(Scala2BlogsDir))))

.PHONY: all