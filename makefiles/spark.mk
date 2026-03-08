SparkBlogsDir := ../spark-algorithms/blogs
SparkBlogsSources := 2025-11-07-SparkDataset \
	2025-12-06-ICIJ-Fraud-Analysis

md_targets += $(foreach wrd,$(SparkBlogsSources),$(DRAFTS_DIR)/$(wrd).md)
asset_targets += $(foreach wrd,$(SparkBlogsSources),$(ASSETS_DIR)/$(wrd))

$(foreach element,$(SparkBlogsSources),$(eval $(call md-copy,$(element),$(SparkBlogsDir))))
$(foreach element,$(SparkBlogsSources),$(eval $(call assets-copy,$(element),$(SparkBlogsDir))))
