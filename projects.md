---
layout: page
title: GitHub
permalink: /projects/
---

Here are my public projects from [GitHub](https://github.com/ojitha):

<div id="projects-container">
  <p>Loading projects...</p>
</div>

<script>
async function loadGitHubProjects() {
  try {
    const response = await fetch('https://api.github.com/users/ojitha/repos?type=public&sort=updated&per_page=100');
    const repos = await response.json();
    
    const excludeList = ['ojitha.github.io', 'blog','JSFEx1'];
    const publicRepos = repos
      .filter(repo => !repo.fork && !excludeList.includes(repo.name))
      .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
    
    let tableHTML = `
      <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
        <thead>
          <tr style="background-color: #f8f9fa;">
            <th style="border: 1px solid #dee2e6; padding: 12px; text-align: left;">Project</th>
            <th style="border: 1px solid #dee2e6; padding: 12px; text-align: left;">Description</th>
            <th style="border: 1px solid #dee2e6; padding: 12px; text-align: left;">Website</th>
            <th style="border: 1px solid #dee2e6; padding: 12px; text-align: left;">Created</th>
          </tr>
        </thead>
        <tbody>
    `;
    
    publicRepos.forEach(repo => {
      const description = repo.description || 'No description available';
      const date = new Date(repo.created_at);
      const createdDate = `${String(date.getMonth() + 1).padStart(2, '0')}/${String(date.getDate()).padStart(2, '0')}/${date.getFullYear()}`;
      const websiteUrl = repo.homepage ? `<a href="${repo.homepage}" target="_blank" style="color: #007bff; text-decoration: none;">🌐 Visit</a>` : '-';
      tableHTML += `
        <tr>
          <td style="border: 1px solid #dee2e6; padding: 12px;">
            <a href="${repo.html_url}" target="_blank" style="color: #007bff; text-decoration: none;">${repo.name}</a>
          </td>
          <td style="border: 1px solid #dee2e6; padding: 12px;">${description}</td>
          <td style="border: 1px solid #dee2e6; padding: 12px;">${websiteUrl}</td>
          <td style="border: 1px solid #dee2e6; padding: 12px;">${createdDate}</td>
        </tr>
      `;
    });
    
    tableHTML += `
        </tbody>
      </table>
      <p style="color: #6c757d; font-size: 0.9em;">Total: ${publicRepos.length} public repositories</p>
    `;
    
    document.getElementById('projects-container').innerHTML = tableHTML;
  } catch (error) {
    document.getElementById('projects-container').innerHTML = '<p style="color: #dc3545;">Error loading projects. Please try again later.</p>';
  }
}

loadGitHubProjects();
</script>

