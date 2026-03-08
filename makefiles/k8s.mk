K8sBlogsDir := ../learn-k8s/blogs
K8sBlogsSources := 2026-01-03-K8sIntro

md_targets += $(foreach wrd,$(K8sBlogsSources),$(DRAFTS_DIR)/$(wrd).md)
asset_targets += $(foreach wrd,$(K8sBlogsSources),$(ASSETS_DIR)/$(wrd))

$(foreach element,$(K8sBlogsSources),$(eval $(call md-copy,$(element),$(K8sBlogsDir))))
$(foreach element,$(K8sBlogsSources),$(eval $(call assets-copy,$(element),$(K8sBlogsDir))))
