LLMTUNINGBlogsDir := ../LLMTuning/blogs
LLMTUNINGBlogsSources := 2026-03-07-ContainerRocm

md_targets += $(foreach wrd,$(LLMTUNINGBlogsSources),$(DRAFTS_DIR)/$(wrd).md)
asset_targets += $(foreach wrd,$(LLMTUNINGBlogsSources),$(ASSETS_DIR)/$(wrd))

$(eval $(call register-section,$(LLMTUNINGBlogsDir),$(LLMTUNINGBlogsSources)))