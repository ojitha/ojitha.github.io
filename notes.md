---
layout: notes
title: Notes
permalink: /notes/
---

<div class="notes-mindmap-container">
  <h3>Notes Knowledge Map</h3>
  <div class="notes-controls">
    <button id="notes-reset-zoom">Reset View</button>
    <select id="notes-category-filter">
      <option value="all">All Categories</option>
    </select>
  </div>
  <div id="notes-mindmap"></div>
</div>

<style>
.notes-mindmap-container {
  width: 100%;
  height: 60vh;
  position: relative;
  margin: 20px 0;
  border: 1px solid #ddd;
  border-radius: 8px;
  background: #fafafa;
}

.notes-controls {
  position: absolute;
  top: 10px;
  left: 10px;
  z-index: 1000;
  background: rgba(255, 255, 255, 0.9);
  padding: 8px;
  border-radius: 5px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.2);
}

.notes-controls button, .notes-controls select {
  margin: 0 3px;
  padding: 4px 8px;
  border: 1px solid #ccc;
  border-radius: 3px;
  background: white;
  cursor: pointer;
  font-size: 12px;
}

.notes-controls button:hover {
  background: #f0f0f0;
}

#notes-mindmap {
  width: 100%;
  height: 100%;
}

.notes-node {
  cursor: pointer;
  stroke: #fff;
  stroke-width: 2px;
}

.notes-node.root {
  fill: #ff6b6b;
}

.notes-node.category {
  fill: #4ecdc4;
}

.notes-node.note {
  fill: #96ceb4;
}

.notes-node.tag {
  fill: #feca57;
}

.notes-link {
  fill: none;
  stroke: #999;
  stroke-opacity: 0.6;
  stroke-width: 1.5px;
}

.notes-node-text {
  font-family: Arial, sans-serif;
  font-size: 11px;
  text-anchor: middle;
  pointer-events: none;
  fill: #333;
}

.notes-tooltip {
  position: absolute;
  text-align: left;
  padding: 8px;
  font-size: 12px;
  background: rgba(0, 0, 0, 0.8);
  color: white;
  border-radius: 4px;
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.3s;
}
</style>

<script src="https://d3js.org/d3.v7.min.js"></script>
<script>
// Notes mindmap data
const notesMindmapData = {
  notes: [
    {% for note in site.data.notes_metadata %}
    {
      title: {{ note.title | jsonify }},
      name: "{{ note.name }}",
      url: "/notes/{{ note.name }}",
      category: "{{ note.category }}",
      tags: {{ note.tags | jsonify }},
      type: "note"
    }{% unless forloop.last %},{% endunless %}
    {% endfor %}
  ]
};

class NotesMindMap {
  constructor(containerId, data) {
    this.container = d3.select(containerId);
    this.data = data;
    this.width = this.container.node().getBoundingClientRect().width;
    this.height = this.container.node().getBoundingClientRect().height;
    this.selectedCategory = 'all';
    
    this.init();
    this.createMindMap();
    this.setupControls();
  }
  
  init() {
    this.svg = this.container
      .append('svg')
      .attr('width', this.width)
      .attr('height', this.height);
    
    this.g = this.svg.append('g');
    
    // Add zoom behavior
    this.zoom = d3.zoom()
      .scaleExtent([0.3, 3])
      .on('zoom', (event) => {
        this.g.attr('transform', event.transform);
      });
    
    this.svg.call(this.zoom);
    
    // Create tooltip
    this.tooltip = d3.select('body')
      .append('div')
      .attr('class', 'notes-tooltip');
  }
  
  processData() {
    const nodes = [];
    const links = [];
    
    // Root node
    const root = {
      id: 'notes-root',
      name: 'My Notes',
      type: 'root',
      x: this.width / 2,
      y: this.height / 2
    };
    nodes.push(root);
    
    // Category and tag sets
    const categories = new Set();
    const tags = new Set();
    
    // Process notes
    this.data.notes.forEach(note => {
      if (this.selectedCategory === 'all' || 
          note.category === this.selectedCategory) {
        
        // Add note node
        const noteNode = {
          id: `note-${note.name}`,
          name: note.title,
          type: 'note',
          url: note.url,
          category: note.category,
          tags: note.tags
        };
        nodes.push(noteNode);
        
        // Add categories and tags
        if (note.category) categories.add(note.category);
        if (note.tags) note.tags.forEach(tag => tags.add(tag));
      }
    });
    
    // Add category nodes
    categories.forEach(cat => {
      const catNode = {
        id: `cat-${cat}`,
        name: cat,
        type: 'category'
      };
      nodes.push(catNode);
      links.push({ source: 'notes-root', target: `cat-${cat}` });
    });
    
    // Add tag nodes (limited to most common ones)
    const tagArray = Array.from(tags).slice(0, 15);
    tagArray.forEach(tag => {
      const tagNode = {
        id: `tag-${tag}`,
        name: tag,
        type: 'tag'
      };
      nodes.push(tagNode);
    });
    
    // Create links for notes
    this.data.notes.forEach(note => {
      if (this.selectedCategory === 'all' || 
          note.category === this.selectedCategory) {
        
        // Link notes to categories
        if (note.category) {
          links.push({
            source: `cat-${note.category}`,
            target: `note-${note.name}`
          });
        } else {
          // Link directly to root if no category
          links.push({
            source: 'notes-root',
            target: `note-${note.name}`
          });
        }
        
        // Link notes to tags (limited)
        if (note.tags) {
          note.tags.slice(0, 3).forEach(tag => {
            if (tagArray.includes(tag)) {
              links.push({
                source: `tag-${tag}`,
                target: `note-${note.name}`
              });
            }
          });
        }
      }
    });
    
    return { nodes, links };
  }
  
  createMindMap() {
    // Clear existing content
    this.g.selectAll('*').remove();
    
    const { nodes, links } = this.processData();
    
    // Create force simulation
    this.simulation = d3.forceSimulation(nodes)
      .force('link', d3.forceLink(links).id(d => d.id).distance(80))
      .force('charge', d3.forceManyBody().strength(-200))
      .force('center', d3.forceCenter(this.width / 2, this.height / 2))
      .force('collision', d3.forceCollide().radius(25));
    
    // Create links
    const link = this.g.append('g')
      .selectAll('line')
      .data(links)
      .enter().append('line')
      .attr('class', 'notes-link');
    
    // Create nodes
    const node = this.g.append('g')
      .selectAll('circle')
      .data(nodes)
      .enter().append('circle')
      .attr('class', d => `notes-node ${d.type}`)
      .attr('r', d => {
        switch(d.type) {
          case 'root': return 18;
          case 'category': return 14;
          case 'note': return 12;
          case 'tag': return 8;
          default: return 10;
        }
      })
      .call(this.drag())
      .on('click', (event, d) => {
        if (d.url) {
          window.open(d.url, '_blank');
        }
      })
      .on('mouseover', (event, d) => {
        this.showTooltip(event, d);
      })
      .on('mouseout', () => {
        this.hideTooltip();
      });
    
    // Add labels
    const labels = this.g.append('g')
      .selectAll('text')
      .data(nodes)
      .enter().append('text')
      .attr('class', 'notes-node-text')
      .text(d => d.name.length > 15 ? d.name.substring(0, 15) + '...' : d.name)
      .attr('dy', d => d.type === 'root' ? 0 : 20);
    
    // Update positions on simulation tick
    this.simulation.on('tick', () => {
      link
        .attr('x1', d => d.source.x)
        .attr('y1', d => d.source.y)
        .attr('x2', d => d.target.x)
        .attr('y2', d => d.target.y);
      
      node
        .attr('cx', d => d.x)
        .attr('cy', d => d.y);
      
      labels
        .attr('x', d => d.x)
        .attr('y', d => d.y);
    });
  }
  
  drag() {
    return d3.drag()
      .on('start', (event, d) => {
        if (!event.active) this.simulation.alphaTarget(0.3).restart();
        d.fx = d.x;
        d.fy = d.y;
      })
      .on('drag', (event, d) => {
        d.fx = event.x;
        d.fy = event.y;
      })
      .on('end', (event, d) => {
        if (!event.active) this.simulation.alphaTarget(0);
        d.fx = null;
        d.fy = null;
      });
  }
  
  showTooltip(event, d) {
    let content = `<strong>${d.name}</strong><br/>Type: ${d.type}`;
    
    if (d.category) content += `<br/>Category: ${d.category}`;
    if (d.tags && d.tags.length) content += `<br/>Tags: ${d.tags.join(', ')}`;
    
    this.tooltip
      .style('opacity', 1)
      .html(content)
      .style('left', (event.pageX + 10) + 'px')
      .style('top', (event.pageY - 10) + 'px');
  }
  
  hideTooltip() {
    this.tooltip.style('opacity', 0);
  }
  
  setupControls() {
    // Reset zoom
    d3.select('#notes-reset-zoom').on('click', () => {
      this.svg.transition().duration(750).call(
        this.zoom.transform,
        d3.zoomIdentity
      );
    });
    
    // Category filter
    const categories = new Set();
    this.data.notes.forEach(note => {
      if (note.category) categories.add(note.category);
    });
    
    const select = d3.select('#notes-category-filter');
    categories.forEach(cat => {
      select.append('option').attr('value', cat).text(cat);
    });
    
    select.on('change', (event) => {
      this.selectedCategory = event.target.value;
      this.createMindMap();
    });
  }
  
  resize() {
    this.width = this.container.node().getBoundingClientRect().width;
    this.height = this.container.node().getBoundingClientRect().height;
    
    this.svg
      .attr('width', this.width)
      .attr('height', this.height);
    
    this.simulation
      .force('center', d3.forceCenter(this.width / 2, this.height / 2))
      .restart();
  }
}

// Initialize the notes mindmap when the page loads
document.addEventListener('DOMContentLoaded', () => {
  const notesMindmap = new NotesMindMap('#notes-mindmap', notesMindmapData);
  
  // Handle window resize
  window.addEventListener('resize', () => {
    notesMindmap.resize();
  });
});
</script>
