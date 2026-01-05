# Variables
DRAFTS_DIR = ./_posts
ASSETS_DIR = ./assets/images

# --- Scala 2 Blogs 
Scala2BlogsDir := ../learn-scala2/blogs
Scala2BlogsSources := 2025-07-25-Scala-basics \
	2025-07-25-Scala-Collections \
	2025-10-24-Scala2Closures \
	2025-10-26-Scala2-Functors \
	2025-10-27-Scala-2-Collections \
	2025-10-31-Functional-Programming-Abstractions-in-Scala

# Create target file lists
md_targets := $(foreach wrd,$(Scala2BlogsSources),$(DRAFTS_DIR)/$(wrd).md)
asset_targets := $(foreach wrd,$(Scala2BlogsSources),$(ASSETS_DIR)/$(wrd))

# --- Spark Blogs
SparkBlogsDir := ../spark-algorithms/blogs
SparkBlogsSources := 2025-11-07-SparkDataset \
	2025-12-06-ICIJ-Fraud-Analysis

# Create target file lists

md_targets += $(foreach wrd,$(SparkBlogsSources),$(DRAFTS_DIR)/$(wrd).md)
asset_targets += $(foreach wrd,$(SparkBlogsSources),$(ASSETS_DIR)/$(wrd))

# --- Bedrock Blogs
BedrockBlogsDir := ../learn-bedrock/blogs
BedrockBlogsSources := 2025-08-29-BedrockLangGraph

md_targets += $(foreach wrd,$(BedrockBlogsSources),$(DRAFTS_DIR)/$(wrd).md)
asset_targets += $(foreach wrd,$(BedrockBlogsSources),$(ASSETS_DIR)/$(wrd))

# -- K8s Blogs
K8sBlogsDir := ../learn-k8s/blogs
K8sBlogsSources := 2026-01-03-K8sIntro

md_targets += $(foreach wrd,$(K8sBlogsSources),$(DRAFTS_DIR)/$(wrd).md)
asset_targets += $(foreach wrd,$(K8sBlogsSources),$(ASSETS_DIR)/$(wrd))

# All target

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

# Generate the rules for Spark posts
$(foreach element,$(SparkBlogsSources),$(eval $(call md-copy,$(element),$(SparkBlogsDir))))
$(foreach element,$(SparkBlogsSources),$(eval $(call assets-copy,$(element),$(SparkBlogsDir))))

# Generate the rules for Bedrock posts
$(foreach element,$(BedrockBlogsSources),$(eval $(call md-copy,$(element),$(BedrockBlogsDir))))
$(foreach element,$(BedrockBlogsSources),$(eval $(call assets-copy,$(element),$(BedrockBlogsDir))))

# Generate the rules for K8
$(foreach element,$(K8sBlogsSources),$(eval $(call md-copy,$(element),$(K8sBlogsDir))))
$(foreach element,$(K8sBlogsSources),$(eval $(call assets-copy,$(element),$(K8sBlogsDir))))

.PHONY: all