---
layout: post
title:  UV is better than Pyenv for Python
date:   2025-06-06
categories: [Python]
toc: true
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

<style>
/* Styles for the two-column layout */
.image-text-container {
    display: flex; /* Enables flexbox */
    flex-wrap: wrap; /* Allows columns to stack on small screens */
    gap: 20px; /* Space between the image and text */
    align-items: center; /* Vertically centers content in columns */
    margin-bottom: 20px; /* Space below this section */
}

.image-column {
    flex: 1; /* Allows this column to grow */
    min-width: 250px; /* Minimum width for the image column before stacking */
    max-width: 40%; /* Maximum width for the image column to not take up too much space initially */
    box-sizing: border-box; /* Include padding/border in element's total width/height */
}

.text-column {
    flex: 2; /* Allows this column to grow more (e.g., twice as much as image-column) */
    min-width: 300px; /* Minimum width for the text column before stacking */
    box-sizing: border-box;
}


</style>

<div class="image-text-container">
    <div class="image-column">
        <img src="/assets/images/2025-06-06-Python_pynv2uvx/UVvsPyenv.png" alt="ADFS SSO for Kibana Diagram" width="150" height="150">
    </div>
    <div class="text-column">
<p>UV is an excellent alternative to Pyenv, though they serve slightly different purposes. I have been using pyenv for more than 10 years. Is this the time for the alternative? It is important to note that UV doesn't support Python 2.*.</p>
    </div>
</div>



<!--more-->

------

* TOC
{:toc}
------

## Comparison

The **UV**[^1] is a modern, fast Python package and project manager written in Rust that handles dependency management, virtual environments, and Python version management. **Pyenv** is specifically designed to manage multiple Python versions on your system.

Here's a detailed comparison:

**Performance**: UV is significantly faster than traditional Python tools, often 10-100x faster than pip for package installation. Pyenv is generally fast for version switching but slower for initial Python version installations.

**Scope**: UV provides a comprehensive solution including package management, virtual environment creation, project scaffolding, and Python version management. Pyenv focuses solely on Python version management and requires additional tools, such as pip and venv, for complete functionality.

**Ease of Use**: UV provides a unified interface for most Python development tasks, featuring commands such as `uv init`, `uv add`, and `uv run`. pyenv has a simpler command set but requires coordination with other tools.

**Python Version Management**: Both can manage multiple Python versions, but UV automatically downloads and manages Python versions as needed, while pyenv requires manual installation of each version.

**Project Management**: UV excels at managing project-level dependencies with lockfiles and reproducible environments. pyenv doesn't handle project dependencies directly.

**Ecosystem Integration**: UV is a newer option but is gaining rapid adoption and integrates well with modern Python workflows. pyenv has been around longer and has broader community support.

UV vs pyenv Comparison Matrix

| Feature                       | UV                                             | pyenv                                        |
| ----------------------------- | ---------------------------------------------- | -------------------------------------------- |
| **Primary Purpose**           | Comprehensive Python package & project manager | Python version management                    |
| **Performance**               | Extremely fast (10-100x faster than pip)       | Fast version switching, slower installations |
| **Package Management**        | ✅ Built-in with lockfiles                      | ❌ Requires separate pip                      |
| **Virtual Environments**      | ✅ Automatic creation and management            | ❌ Requires separate venv/virtualenv          |
| **Python Version Management** | ✅ Automatic download and management            | ✅ Manual installation required               |
| **Project Scaffolding**       | ✅ `UV init` creates complete project structure | ❌ No project management                      |
| **Dependency Resolution**     | ✅ Advanced resolver with conflict detection    | ❌ Relies on pip                              |
| **Lockfiles**                 | ✅ `UV.lock` for reproducible builds            | ❌ No lockfile support                        |
| **Cross-platform**            | ✅ Windows, macOS, Linux                        | ✅ Windows, macOS, Linux                      |
| **Installation Method**       | Single binary, pip, or package managers        | Git clone + shell integration                |
| **Learning Curve**            | Moderate (new tool, comprehensive)             | Low (simple commands)                        |
| **Community Adoption**        | Growing rapidly (newer tool)                   | Mature and widespread                        |
| **Integration**               | Works with existing Python tools               | Seamless with traditional workflow           |
| **Memory Usage**              | Low (Rust-based)                               | Low                                          |
| **Configuration**             | `pyproject.toml` based                         | Shell profile based                          |
| **Shims/PATH Management**     | Automatic in projects                          | Global PATH manipulation                     |
| **Version Pinning**           | ✅ Per-project in `pyproject.toml`              | ✅ Per-directory with `.python-version`       |

## Recommendation

**Choose UV if:**

- You want a modern, all-in-one solution
- You're starting new projects
- You value speed and efficiency
- You want built-in dependency management
- You prefer declarative configuration

**Choose Pyenv if:**

- You only need Python version management
- You're working with existing workflows
- You prefer minimal, focused tools
- You need maximum compatibility with legacy projects
- You're comfortable with the traditional Python toolchain

**Best of both worlds:** Many developers use UV for new projects while keeping pyenv for system-level Python version management.

## Setup

There are three ways to set up

Using URL:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

If you are still need to keep pyenv and need to use UV:

```bash
# Using pip
pip install uv
```

On MacOS:

```bash
brew install uv
```

List installed Python versions

```bash
uv python list --only-installed
```

For example, 

![List installed Python versions](/assets/images/2025-06-06-Python_pynv2uvx/List_installed_Python_versions.jpg)

1. Installing Python 3.10.1: This downloads and automatically installs Python 3.10.1. UV manages the installation location and makes it available for your projects.

    ```bash
    # List available Python versions
    uv python list
    
    # INSTALL PYTHON 3.10.1
    uv python install 3.10.1
    ```

    

2. Creating a project:

    ```bash
    uv init --python 3.10.1 my-project
    ```

    This creates a complete project structure with:

    - A `pyproject.toml` file with Python 3.10.1 specified
    - A virtual environment using Python 3.10.1
    - Sample files to get you started

    Alternative way to create the project:

    ```bash
    mkdir my-python-project
    cd my-python-project
    
    # Initialise project with specific Python version
    uv init --python 3.10.1
    ```

    Project structure is

    ```
    my-python-project/
      ├── .venv/              # Virtual environment (created automatically)
      ├── .python-version     # Python version specification
      ├── pyproject.toml      # Project configuration and dependencies
      ├── README.md           # Project documentation
      └── hello.py            # Sample Python file
    ```

    

3. Running your project scripts:

    ```bash
    uv run python main.py
    ```

    This automatically uses the correct Python version and virtual environment without manual activation.

4. Add packages to your project

    ```bash
    uv add requests
    uv add pandas numpy
    uv add pytest --dev  # Development dependency
    ```

    Add package with version constraint

    ```bash
    uv add "django>=4.0,<5.0"
    ```

    or install all dependencies from pyproject.toml

    ```bash
    uv sync
    ```

5. Run Python commands in the project environment

    ```bash
    uv run python --version
    uv run python -c "import sys; print(sys.version)"
    ```

    

6. Start Python REPL

    ```bash
    uv run python
    ```

    or run a module

    ```bash
    # Run a module
    uv run python -m pytest
    ```

    

Key advantages of UV's approach:

- *Automatic virtual environment*: No need to manually create or activate virtual environments
- *Integrated dependency management*: Add packages with `uv add` instead of `pip install`
- *Fast operations*: Dependencies install much faster than traditional pip
- *Reproducible builds*: The `uv.lock` file ensures consistent installations

UV automatically creates virtual environments, but you can be explicit:

```bash
# Create virtual environment with specific Python version
uv venv --python 3.10.1
```

or

```bash
# Create virtual environment in custom location
uv venv .venv --python 3.10.1
```

Activate the virtual environment (traditional way)

```bash
source .venv/bin/activate  # On Linux/macOS
or
.venv\Scripts\activate     # On Windows
```

Other useful commands:

```bash
# Show project information
uv info

# Show dependency tree
uv tree

# Lock dependencies (create uv.lock)
uv lock

# Update dependencies
uv lock --upgrade

# Remove a package
uv remove requests

# Show outdated packages
uv tree --outdated

# Export requirements.txt (for compatibility)
uv export --format requirements-txt > requirements.txt
```

Environment variables and configurations:

```bash
# ENVIRONMENT VARIABLES AND CONFIGURATION
# ---------------------------------------
# Set Python version for project
echo "3.10.1" > .python-version

# uv will automatically use this version for the project

# ADVANCED: WORKING WITH MULTIPLE PYTHON VERSIONS
# -----------------------------------------------
# Install multiple Python versions
uv python install 3.10.1 3.11.5 3.12.0

# Create project with different Python versions
uv init --python 3.11.5 project-py311
uv init --python 3.12.0 project-py312

# Switch Python version for existing project
uv python pin 3.11.5
```



## Example workflow

As a developer, this is your typical workflow using UV:

``` bash
# Step 1: Create and initialize project
uv init --python 3.10.1 my-web-app
cd my-web-app

# Step 2: Add dependencies
uv add fastapi uvicorn
uv add pytest black --dev

# Step 3: Create main application file
echo 'from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
' > main.py

# Step 4: Run the application
uv run python main.py

# Step 5: Run tests
uv run pytest

# Step 6: Format code
uv run black .
```

Working with existing projects:

```bash
# If you have an existing project with requirements.txt:

# Convert requirements.txt to pyproject.toml
uv add --requirements requirements.txt

# Install dependencies from pyproject.toml
uv sync
```



[^1]: [UV](https://docs.astral.sh/uv/)
