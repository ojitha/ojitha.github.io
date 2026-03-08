BedrockBlogsDir := ../learn-bedrock/blogs
BedrockBlogsSources := 2025-08-29-BedrockLangGraph

md_targets += $(foreach wrd,$(BedrockBlogsSources),$(DRAFTS_DIR)/$(wrd).md)
asset_targets += $(foreach wrd,$(BedrockBlogsSources),$(ASSETS_DIR)/$(wrd))

$(foreach element,$(BedrockBlogsSources),$(eval $(call md-copy,$(element),$(BedrockBlogsDir))))
$(foreach element,$(BedrockBlogsSources),$(eval $(call assets-copy,$(element),$(BedrockBlogsDir))))
