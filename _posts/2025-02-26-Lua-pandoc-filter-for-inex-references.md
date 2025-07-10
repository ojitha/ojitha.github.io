---
layout: post
title:  Lua filters for Pandoc
date:   2025-02-28
categories: [Lua]
mermaid: true
toc: true
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

Lua filter used in Pandoc 3.6.3. This blog has solutions for:

- Creating Glossary for ePub ver 3 book
- GitHub style alerts

<!--more-->

------

* TOC
{:toc}
------

## Glossary Filter

This filter creates a glossary for ePub 3 using index term such as `[Important Concept]{.index}`. The links of the glossary item are pointing to this index item in the ePub book.


![Glossary Example](/assets/images/2025-02-26-Lua-pandoc-filter-for-inex-references/Glossary Example.jpg){:width="50%", hight="50%"}

When the links are sorted by number, starting from the book, you can navigate to the link. This is similar to the traditional index on a page, where you search by page number.


**Section Number Tracking**:

- Added section tracking functionality that extracts section numbers from headers when Pandoc uses `--number-sections`
- The filter now maintains information about the current section structure as it processes the document

**Header Processing**:

- Added a `Header()` function to capture section numbers and titles
- Parses headers to extract section numbering in the format "1.2.3 Section Title"

**Section Information Storage**:

- Stores section numbers and titles in a lookup table using header identifiers
- Records the current section hierarchy to associate indexed terms with their containing sections

**Updated Index Entries**:

- Each index entry now stores both the section number and section title
- Links in the index display the section number (e.g., "1.2.3") instead of the term text or a counter
- Added tooltips with section titles when hovering over the links

To create the ePub

```bash
pandoc --number-sections --lua-filter=epub-index-section-numbers.lua *.md -o book.epub
```

The `--number-sections` flag is essential as it generates the section numbers that this filter will use for the index references.

```lua
-- epub-index-section-numbers.lua: A Pandoc Lua filter to create an index for ePub with links referencing section numbers
-- Save this file as epub-index-section-numbers.lua and use with: pandoc --number-sections --lua-filter=epub-index-section-numbers.lua *.md -o book.epub

-- Table to store all index entries
local index_entries = {}
local current_filename = ""
local section_numbers = {}  -- Section number at each level

-- Function to sanitize index keys
local function sanitize_key(text)
  text = text:gsub("[%p%c%s]", ""):lower()
  return text
end

-- Track current file being processed
function Meta(meta)
  -- Try to get the current filename from metadata
  if meta.filename then
    current_filename = pandoc.utils.stringify(meta.filename)
  end
  return meta
end

-- Keep track of section information
local current_section_number = nil
local section_header_map = {}  -- Maps header identifiers to their full section numbers
local in_header = false

-- Function to get current complete section number
local function get_current_section_number()
  local parts = {}
  for i = 1, #section_numbers do
    if section_numbers[i] then
      table.insert(parts, tostring(section_numbers[i]))
    end
  end
  
  if #parts > 0 then
    return table.concat(parts, ".")
  else
    return nil
  end
end

-- Process headers to track section numbers
function Header(el)
  -- Track if we're inside a header (to prevent processing index terms inside headers)
  in_header = true
  
  -- Adjust section_numbers table based on header level
  while #section_numbers > el.level do
    table.remove(section_numbers)
  end
  
  while #section_numbers < el.level do
    table.insert(section_numbers, 0)
  end
  
  -- Extract section number from header content if it exists
  local header_text = pandoc.utils.stringify(el.content)
  local extracted_section_number = header_text:match("^([%d%.]+)%s+")
  
  if extracted_section_number then
    -- If Pandoc has already numbered this section, use that number
    local section_parts = {}
    for num in extracted_section_number:gmatch("%d+") do
      table.insert(section_parts, tonumber(num))
    end
    
    -- Update section_numbers with the extracted values
    for i = 1, math.min(#section_parts, el.level) do
      section_numbers[i] = section_parts[i]
    end
    
    -- Store the clean section title (without the number)
    local section_title = header_text:gsub("^[%d%.]+%s+", "")
    
    -- Store mapping from header ID to section number and title
    section_header_map[el.identifier] = {
      number = extracted_section_number,
      title = section_title
    }
    
    current_section_number = extracted_section_number
  else
    -- If Pandoc hasn't numbered this section (shouldn't happen with --number-sections)
    -- Just increment the current level
    section_numbers[el.level] = (section_numbers[el.level] or 0) + 1
    
    -- Reconstruct the section number
    current_section_number = get_current_section_number()
    
    -- Store mapping
    section_header_map[el.identifier] = {
      number = current_section_number,
      title = header_text
    }
  end
  
  in_header = false
  return el
end

-- Function to add an entry to the index
local function add_index_entry(entry, anchor_id, display_text)
  if not entry or entry == "" then
    return
  end
  
  -- Get current section number for this entry
  local section_number = current_section_number or ""
  local section_title = ""
  
  -- Process entry for subentries (separated by colon)
  local main_entry, sub_entry = entry:match("^([^:]+):?(.*)$")
  main_entry = main_entry:gsub("^%s*(.-)%s*$", "%1") -- Trim
  
  if not index_entries[main_entry] then
    index_entries[main_entry] = {
      locations = {},
      subentries = {}
    }
  end
  
  if sub_entry and sub_entry ~= "" then
    sub_entry = sub_entry:gsub("^%s*(.-)%s*$", "%1") -- Trim
    if not index_entries[main_entry].subentries[sub_entry] then
      index_entries[main_entry].subentries[sub_entry] = {
        locations = {}
      }
    end
    table.insert(index_entries[main_entry].subentries[sub_entry].locations, {
      id = anchor_id,
      file = current_filename,
      text = display_text,
      section_number = section_number,
      section_title = section_title
    })
  else
    table.insert(index_entries[main_entry].locations, {
      id = anchor_id,
      file = current_filename,
      text = display_text,
      section_number = section_number,
      section_title = section_title
    })
  end
end

-- Process Span elements with "index" class
function Span(el)
  if in_header then
    return el  -- Skip processing inside headers to avoid affecting section number extraction
  end
  
  if el.classes:includes("index") then
    local index_text = pandoc.utils.stringify(el.content)
    
    if index_text ~= "" then
      -- Create a unique identifier
      local id = "idx-" .. sanitize_key(index_text) .. "-" .. os.time() .. "-" .. math.random(1000)
      
      -- Get the display text (the actual content)
      local display_text = pandoc.utils.stringify(el.content)
      
      -- Add to index
      add_index_entry(index_text, id, display_text)
      
      -- Return span with ID
      return pandoc.Span(el.content, {id = id, class = "indexed-term"})
    end
  end
  return el
end

-- Process RawInlines for special index notation if needed
function RawInline(el)
  if in_header then
    return el  -- Skip processing inside headers
  end
  
  if el.format == "html" or el.format == "epub" then
    -- Match any custom index format like `<<term>>` or similar
    local index_term = el.text:match("<<(.-)>>")
    if index_term then
      local id = "idx-" .. sanitize_key(index_term) .. "-" .. os.time() .. "-" .. math.random(1000)
      add_index_entry(index_term, id, index_term)
      -- Return a span that will be rendered with the term and an ID
      return pandoc.Span(pandoc.Str(index_term), {id = id, class = "indexed-term"})
    end
  end
  return el
end

-- Process Div elements with "index" class (for block-level indexing)
function Div(el)
  if el.classes:includes("index") then
    local index_text = pandoc.utils.stringify(el.content)
    
    if index_text ~= "" then
      -- Create a unique identifier
      local id = "idx-" .. sanitize_key(index_text) .. "-" .. os.time() .. "-" .. math.random(1000)
      
      -- Add to index
      add_index_entry(index_text, id, index_text)
      
      -- Add the ID to the div
      el.attributes.id = id
      el.classes:insert("indexed-term")
      
      return el
    end
  end
  return el
end

-- Debug function to log section numbers if needed
local function debug_log(message)
  -- Enable for debugging
  -- io.stderr:write(message .. "\n")
end

-- Generate the index as a separate chapter at the end of the document
function Pandoc(doc)
  -- Only generate index once all files are processed
  -- Skip if no index entries
  if next(index_entries) == nil then
    return doc
  end
  
  -- Sort the entries alphabetically
  local sorted_entries = {}
  for entry, data in pairs(index_entries) do
    table.insert(sorted_entries, {
      text = entry,
      data = data
    })
  end
  
  table.sort(sorted_entries, function(a, b) 
    return a.text:lower() < b.text:lower() 
  end)
  
  -- Create the index content
  local index_blocks = {
    pandoc.Header(1, "Index")
  }
  
  local current_letter = nil
  
  for _, entry in ipairs(sorted_entries) do
    local first_letter = entry.text:sub(1, 1):upper()
    
    -- Add letter divider if this is a new letter
    if first_letter ~= current_letter then
      current_letter = first_letter
      table.insert(index_blocks, pandoc.Para(pandoc.Strong(current_letter)))
    end
    
    -- Create entry line
    local entry_content = {}
    table.insert(entry_content, pandoc.Str(entry.text))
    
    -- Add links to occurrences
    if #entry.data.locations > 0 then
      table.insert(entry_content, pandoc.Space())
      for i, location in ipairs(entry.data.locations) do
        if i > 1 then
          table.insert(entry_content, pandoc.Str(","))
          table.insert(entry_content, pandoc.Space())
        end
        
        -- Use section number as the link text if available, otherwise fallback to location index
        local link_text = location.section_number
        if not link_text or link_text == "" then
          link_text = tostring(i)
        end
        
        -- Add tooltip with section title if available
        local attrs = {}
        if location.section_title and location.section_title ~= "" then
          attrs.title = location.section_title
        end
        
        -- Create the link to the indexed term
        table.insert(entry_content, pandoc.Link(link_text, "#" .. location.id, "", attrs))
      end
    end
    
    table.insert(index_blocks, pandoc.Para(entry_content))
    
    -- Add subentries if any
    local sorted_subentries = {}
    for subentry, subdata in pairs(entry.data.subentries) do
      table.insert(sorted_subentries, {
        text = subentry,
        data = subdata
      })
    end
    
    table.sort(sorted_subentries, function(a, b) 
      return a.text:lower() < b.text:lower() 
    end)
    
    for _, subentry in ipairs(sorted_subentries) do
      local subentry_content = {
        pandoc.Str("    • "), -- Indent subentries
        pandoc.Str(subentry.text)
      }
      
      -- Add links to occurrences
      if #subentry.data.locations > 0 then
        table.insert(subentry_content, pandoc.Space())
        for i, location in ipairs(subentry.data.locations) do
          if i > 1 then
            table.insert(subentry_content, pandoc.Str(","))
            table.insert(subentry_content, pandoc.Space())
          end
          
          -- Use section number as the link text if available
          local link_text = location.section_number
          if not link_text or link_text == "" then
            link_text = tostring(i)
          end
          
          -- Add tooltip with section title if available
          local attrs = {}
          if location.section_title and location.section_title ~= "" then
            attrs.title = location.section_title
          end
          
          -- Create the link to the indexed term
          table.insert(subentry_content, pandoc.Link(link_text, "#" .. location.id, "", attrs))
        end
      end
      
      table.insert(index_blocks, pandoc.Para(subentry_content))
    end
  end
  
  -- Create a div for the index with special styling
  local index_div = pandoc.Div(index_blocks, {id = "book-index", class = "index-section"})
  
  -- Add CSS styling for indexed terms and index entries
  local css = [[
<style>
.indexed-term {
  /* Optional: add subtle highlighting to indexed terms */
  /* background-color: rgba(255, 255, 0, 0.1); */
}

.index-section a {
  /* Style for section number links */
  text-decoration: none;
  color: #0066cc;
}

.index-section a:hover {
  text-decoration: underline;
}
</style>
  ]]
  
  -- Add the CSS if we're generating HTML or EPUB
  if FORMAT:match "html" or FORMAT:match "epub" then
    table.insert(doc.blocks, 1, pandoc.RawBlock("html", css))
  end
  
  -- Add the index to the end of the document
  doc.blocks:insert(index_div)
  
  return doc
end

-- Return the filter
return {
  Header = Header,
  Span = Span,
  Div = Div,
  RawInline = RawInline,
  Meta = Meta,
  Pandoc = Pandoc
}
```

## Alerts

You can create GitHub-style alerts in Pandoc Markdown by leveraging **fenced `div` blocks** and **CSS styling**. Pandoc allows you to attach classes to these `div` blocks, which you can then target with CSS to create the visual alert boxes.

Here's how you can do it:

### Markdown with Fenced Divs and Classes

In your Markdown document (`my_document.md`), use fenced `div` blocks with classes to represent different alert types. Common GitHub alert types are:

- **Note:** General information, hints.
- **Tip/Important:** Important information, best practices.
- **Warning:** Potential issues, things to be careful about.
- **Danger/Error:** Critical issues, things to avoid.

You can represent these like this in Markdown:

```markdown
::: note
**Note:** This is a note alert box.
It can contain multiple paragraphs and even lists.

- Item 1
- Item 2
:::

::: tip
**Tip:** Here's a helpful tip!
:::

::: warning
**Warning:**  Be careful with this action!
:::

::: danger
**Danger:** This is a dangerous operation. Proceed with caution!
:::

```

**Explanation of the Markdown Syntax:**

- `::: note`, `::: tip`, `::: warning`, `::: danger`: These are fenced `div` blocks. The word after `:::` is treated as the **class name** for the `div` element in the output HTML (or other formats).
- The content inside the `::: ... :::` block is the content of the `div`.
- You can use standard Markdown formatting inside the alert boxes (bold, italics, lists, etc.).

### CSS Styling (`styles.css`)

Create a CSS file (e.g., `styles.css`) to style the `div` elements with the classes you used in your Markdown. This CSS will define the visual appearance of your alerts, mimicking GitHub's style (you can customise this to your liking).

Here's an example `styles.css` that creates alert boxes with different background colors and border styles:

```css
.note, .tip, .warning, .danger {
  padding: 1em;
  margin-bottom: 1em;
  border-radius: 5px;
  border-left: 5px solid;
}

.note {
  background-color: #e8f0fe; /* Light blue */
  border-color: #4285f4;    /* Blue */
}

.tip {
  background-color: #f0f9ed;   /* Light green */
  border-color: #34a853;      /* Green */
}

.warning {
  background-color: #fff8e1;  /* Light yellow */
  border-color: #ffb300;     /* Yellow/Amber */
}

.danger {
  background-color: #fde2e2;  /* Light red */
  border-color: #e53935;     /* Red */
  color: #842029;           /* Darker text for readability on red */
}

/* Optional: Style the bold title within alerts */
.note strong, .tip strong, .warning strong, .danger strong {
    display: block; /* Make the strong element a block for better spacing */
    margin-bottom: 0.5em; /* Add some space below the title */
}
```

**Explanation of the CSS:**

- `.note, .tip, .warning, .danger`: This selector targets all the `div` elements with these classes.
    - `padding`, `margin-bottom`, `border-radius`, `border-left`: Basic styling to create the box appearance.
- `.note`, .tip, .warning, .danger` (individual styles): Specific styles for each alert type:
    - `background-color`: Sets the background color.
    - `border-color`: Sets the color of the left border (for visual emphasis, like GitHub).
    - `color` (for `.danger`): Adjusts text color if needed for better contrast against the background.

- `.note strong, .tip strong, .warning strong, .danger strong`: Optional styling to make the bold text (used for titles like "Note:", "Tip:", etc.) stand out a bit more within the alerts.

Much more simplier icon[^1] with markdown may be the best:

```
:boom: DANGER, Will Robinson, DANGER
> :memo: **This is a Note**: a pen in front of a paper

> :warning: **This is a Note**: an exclamation mark in front of a triangle

> :bulb: **This is a Note**: a light bulb

> :heavy_check_mark: **This is a Note**: a check mark

:sleeping: This text is all part of a single *admonition* block.
```

Output:

:boom: DANGER, Will Robinson, DANGER

> :memo: **This is a Note**: a pen in front of a paper

> :warning: **This is a Note**: an exclamation mark in front of a triangle

> :bulb: **This is a Note**: a light bulb

> :heavy_check_mark: **This is a Note**: a check mark

:sleeping: This text is all part of a single *admonition* block.

## pandoc-crossref
Here is simple configuration as in the crossref[^2]

```
---
codeBlockCaptions: True
figureTitle: |
  Fig.
figPrefix:
    - "Fig."
    - "Figs"
tblPrefix:
    - "Table"
    - "Tables"
lofTitle: |
  ## List of Figures
lotTitle: |
  ## List of Tables
lolTitle: |
  ## List of Listings
tableTemplate: |
  *$$tableTitle$$ $$i$$*$$titleDelim$$ $$t$$
autoSectionLabels: True
---
```

Reference:

****

[^1]: [A markdown version emoji cheat sheet](https://github.com/ikatyang/emoji-cheat-sheet/tree/master)
[^2]: [pandoc-crossref](https://lierdakil.github.io/pandoc-crossref/#customization)