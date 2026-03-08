LLMTUNINGBlogsDir := ../LLMTuning/blogs
LLMTUNINGBlogsSources := 2026-02-14-SMMLDev

md_targets += $(foreach wrd,$(LLMTUNINGBlogsSources),$(DRAFTS_DIR)/$(wrd).md)
asset_targets += $(foreach wrd,$(LLMTUNINGBlogsSources),$(ASSETS_DIR)/$(wrd))

$(foreach element,$(LLMTUNINGBlogsSources),$(eval $(call md-copy,$(element),$(LLMTUNINGBlogsDir))))
$(foreach element,$(LLMTUNINGBlogsSources),$(eval $(call assets-copy,$(element),$(LLMTUNINGBlogsDir))))
