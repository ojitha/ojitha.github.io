PyTipsBlogsDir := ../pythontips/blogs
PyTipsBlogsSources := 2026-10-18-PythonIntro
md_targets += $(foreach wrd,$(PyTipsBlogsSources),$(DRAFTS_DIR)/$(wrd).md)
asset_targets += $(foreach wrd,$(PyTipsBlogsSources),$(ASSETS_DIR)/$(wrd))

# $(foreach element,$(PyTipsBlogsSources),$(eval $(call md-copy,$(element),$(PyTipsBlogsDir))))
# $(foreach element,$(PyTipsBlogsSources),$(eval $(call assets-copy,$(element),$(PyTipsBlogsDir))))
$(eval $(call register-section,$(PyTipsBlogsDir),$(PyTipsBlogsSources)))