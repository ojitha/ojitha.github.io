LLMTUNINGBlogsDir := ../LLMTuning/blogs
LLMTUNINGBlogsSources := 2026-03-07-ContainerRocm 2026-05-05-Gemma4

md_targets += $(foreach wrd,$(LLMTUNINGBlogsSources),$(DRAFTS_DIR)/$(wrd).md)
asset_targets += $(foreach wrd,$(LLMTUNINGBlogsSources),$(ASSETS_DIR)/$(wrd))

$(eval $(call register-section,$(LLMTUNINGBlogsDir),$(LLMTUNINGBlogsSources)))