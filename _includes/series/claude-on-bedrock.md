This post is part of a series on **Claude on AWS Bedrock**

{% capture series %}
[Claude on Amazon Bedrock - EVALS & Prompt Engineering]({% link _posts/2026-09-13-BedrocClaude_1.md %}){:target="_blank" rel="noopener noreferrer}
[Claude on Amazon Bedrock - Tool use basics]({% link _posts/2026-09-16-BedrockClaude_2.md %}){:target="_blank" rel="noopener noreferrer}
[Claude on Amazon Bedrock - Mastering Tool Use and Structured Data]({% link _posts/2026-09-18-BedrockClaude_3.md %}){:target="_blank" rel="noopener noreferrer}
[Claude RAG on Amazon Bedrock]({% link _posts/2026-09-19-BedrockClaude_4.md %}){:target="_blank" rel="noopener noreferrer}
[Claude Extended Thinking on Amazon Bedrock]({% link _posts/2026-09-20-BedrockClaude_5.md %}){:target="_blank" rel="noopener noreferrer}
[Claude MCP on Amazon Bedrock]({% link _posts/2026-09-21-BedrockClaude_6.md %}){:target="_blank" rel="noopener noreferrer}
{% endcapture %}
{% assign items = series | strip | newline_to_br | split: "<br />" %}
{% assign current = include.current | plus: 0 %}
{% for item in items -%}
{{ forloop.index }}. {% if forloop.index == current %}**{{ item | strip }}**{% else %}{{ item | strip }}{% endif %}
{% endfor %}