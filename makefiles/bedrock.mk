BedrockBlogsDir := ../learn-bedrock/blogs
BedrockBlogsSources := 2025-08-29-BedrockLangGraph \
	2026-09-13-BedrocClaude_1 \
	2026-09-16-BedrockClaude_2 \
	2026-09-18-BedrockClaude_3

md_targets += $(foreach wrd,$(BedrockBlogsSources),$(DRAFTS_DIR)/$(wrd).md)
asset_targets += $(foreach wrd,$(BedrockBlogsSources),$(ASSETS_DIR)/$(wrd))

# $(foreach element,$(BedrockBlogsSources),$(eval $(call md-copy,$(element),$(BedrockBlogsDir))))
# $(foreach element,$(BedrockBlogsSources),$(eval $(call assets-copy,$(element),$(BedrockBlogsDir))))
$(eval $(call register-section,$(BedrockBlogsDir),$(BedrockBlogsSources)))