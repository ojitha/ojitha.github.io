Scala2BlogsDir := ../learn-scala2/blogs
Scala2BlogsSources := 2025-07-25-Scala-basics \
	2025-07-25-Scala-Collections \
	2025-10-24-Scala2Closures \
	2025-10-26-Scala2-Functors \
	2025-10-27-Scala-2-Collections \
	2025-10-31-Functional-Programming-Abstractions-in-Scala

md_targets += $(foreach wrd,$(Scala2BlogsSources),$(DRAFTS_DIR)/$(wrd).md)
asset_targets += $(foreach wrd,$(Scala2BlogsSources),$(ASSETS_DIR)/$(wrd))

$(foreach element,$(Scala2BlogsSources),$(eval $(call md-copy,$(element),$(Scala2BlogsDir))))
$(foreach element,$(Scala2BlogsSources),$(eval $(call assets-copy,$(element),$(Scala2BlogsDir))))
