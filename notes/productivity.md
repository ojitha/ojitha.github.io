---
layout: notes
title: Productivity Tools
mermaid: true
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../../blog/assets/images/${filename}
---

---

* TOC
{:toc}

---


## Blog tools
### Makefile for Jekyll

The pattern lets you onboard a new external blog source by writing a tiny include file — set its `…BlogsDir`, list its stems, and reuse the same `md-copy` / `assets-copy` templates.

The build is split between a top-level `Makefile` (which defines reusable rule *templates*) and per-section include files, such as `makefiles/llmtuning.mk` (which list *which* posts to pull and *where* to pull them from). The variable `LLMTUNINGBlogsDir := ../LLMTuning/blogs` is the "where"—it tells the templates the source directory for the LLMTuning Jupyter-notebook-derived markdown files, which sit one level above the Jekyll site.

#### Step 1 — Templates defined in the top-level Makefile

```makefile
# Markdown copy rule
define md-copy
$(DRAFTS_DIR)/$1.md : $2/$1.md | $(DRAFTS_DIR)
	@echo "-------------------------"
	@echo "copy $$< -> $$@"
	cp $$< $$@
	@echo "-------------------------"
endef

# Assets copy rule
define assets-copy
$(ASSETS_DIR)/$1:
	@echo "Checking for assets folder $1..."
	@if [ -d "$2/assets/images/$1" ]; then \
		echo "Assets folder exists, copying..."; \
		mkdir -p $(ASSETS_DIR)/$1; \
		cp -r $2/assets/images/$1/* $(ASSETS_DIR)/$1/; \
		echo "Assets copied to $(ASSETS_DIR)/$1"; \
	else \
		echo "No assets folder found for $1, creating empty directory..."; \
		mkdir -p $(ASSETS_DIR)/$1; \
	fi
endef
```



The above two `define` blocks act as parameterised rule generators:

- `md-copy` takes two arguments: `$1` is the post stem (e.g. `2026-02-14-SMMLDev`) and `$2` is the source directory. It produces a rule of the form:

```makefile
./_posts/2026-02-14-SMMLDev.md : ../LLMTuning/blogs/2026-02-14-SMMLDev.md | ./_posts
    cp ../LLMTuning/blogs/2026-02-14-SMMLDev.md ./_posts/2026-02-14-SMMLDev.md
```

- `assets-copy` similarly generates a rule that creates `./assets/images/<stem>/`, and if `<source>/assets/images/<stem>/` exists, copies its contents over; otherwise it just makes the empty directory.

> The double-dollar `$$<` and `$$@` inside `define` are essential — they survive one level of `$(call ...)` expansion so that `$<` and `$@` end up in the final rule for `make` to interpret as the prerequisite and target.



#### Step 2 — `llmtuning.mk` plugs values into those templates



```makefile
LLMTUNINGBlogsDir := ../LLMTuning/blogs
LLMTUNINGBlogsSources := 2026-02-14-SMMLDev \
							2026-03-07-ContainerRocm

md_targets += $(foreach wrd,$(LLMTUNINGBlogsSources),$(DRAFTS_DIR)/$(wrd).md)
asset_targets += $(foreach wrd,$(LLMTUNINGBlogsSources),$(ASSETS_DIR)/$(wrd))

$(foreach element,$(LLMTUNINGBlogsSources),$(eval $(call md-copy,$(element),$(LLMTUNINGBlogsDir))))
$(foreach element,$(LLMTUNINGBlogsSources),$(eval $(call assets-copy,$(element),$(LLMTUNINGBlogsDir))))
```



The above include file does four things, in order:

`LLMTUNINGBlogsDir := ../LLMTuning/blogs` sets the source path. The path is relative to the repo root (`/Users/...same.../ojitha.github.io`), so it resolves to `/Users/...same.../LLMTuning/blogs` — the sibling repo you mentioned attaching.

`LLMTUNINGBlogsSources := 2026-02-14-SMMLDev 2026-03-07-ContainerRocm` is the list of post stems to import.

The two `md_targets += …` and `asset_targets += …` lines extend the global target lists that the top-level `all:` target depends on. After expansion, they become:

```
md_targets    += ./_posts/2026-02-14-SMMLDev.md ./_posts/2026-03-07-ContainerRocm.md
asset_targets += ./assets/images/2026-02-14-SMMLDev ./assets/images/2026-03-07-ContainerRocm
```

The two `$(foreach … $(eval $(call …)))` lines are where `LLMTUNINGBlogsDir` is actually consumed. For each stem in `LLMTUNINGBlogsSources`, `$(call md-copy,<stem>,../LLMTuning/blogs)` expands the template with `$1=<stem>` and `$2=../LLMTuning/blogs`, and `$(eval …)` injects the resulting rule text into the Makefile as if it had been written by hand. The same happens for `assets-copy`.

#### Step 3 — What `make all` actually does

After all the eval'ing, the effective Makefile contains, for each stem, two concrete rules:

```
./_posts/2026-02-14-SMMLDev.md : ../LLMTuning/blogs/2026-02-14-SMMLDev.md | ./_posts
    cp ../LLMTuning/blogs/2026-02-14-SMMLDev.md ./_posts/2026-02-14-SMMLDev.md

./assets/images/2026-02-14-SMMLDev:
    # if ../LLMTuning/blogs/assets/images/2026-02-14-SMMLDev exists, copy it
    # otherwise create an empty directory
```

`all` depends on `$(md_targets) $(asset_targets)`, so `make` walks each target. Markdown files are rebuilt only dependency). The asset rule has no prerequisites, so it runs once and is then considered up to date.

#### Why this design

The one caveat worth noting: the markdown rule has the source as a real prerequisite (so edits in `../LLMTuning/blogs` trigger a re-copy), but the assets rule does not — once `./assets/images/<stem>` exists, `make` will not refresh it even if images change upstream. If that matters, deleting the target directory before `make all` (or adding the source folder as an order-only prerequisite) forces the recopy.

![makefile_llmtuning_flow](https://raw.githubusercontent.com/ojitha/blog/master/assets/images/productivity/makefile_llmtuning_flow.svg)

**Step 1 — Declare what to import.** When `make` reads `Makefile` and hits the `include makefiles/llmtuning.mk` line, the variables `LLMTUNINGBlogsDir` and `LLMTUNINGBlogsSources` are set. The first one points one directory up at the sibling `LLMTuning` repo's `blogs/` folder; the second one is the explicit list of post stems you want to pull in. Nothing has been copied yet — these are just strings sitting in `make`'s memory.

**Step 2 — Templates wait to be filled in.** Earlier in the top-level Makefile, two `define` blocks (`md-copy` and `assets-copy`) declared *parameterised* rule fragments. They contain `$1` and `$2` placeholders — `$1` for the post stem, `$2` for the source directory. They are not rules yet; they are recipes for making rules. The doubled `$$<` and `$$@` inside them are intentional — they survive one round of `$(call)` substitution and arrive at `make` as the normal automatic variables ` $<` and `$@`.

**Step 3 — `foreach` + `eval` + `call` turns templates into real rules.** This is the line that does the actual wiring:

```
$(foreach element,$(LLMTUNINGBlogsSources),$(eval $(call md-copy,$(element),$(LLMTUNINGBlogsDir))))
```

`$(foreach)` walks each stem (`2026-02-14-SMMLDev`, then `2026-03-07-ContainerRocm`). For each one, `$(call md-copy,<stem>,../LLMTuning/blogs)` substitutes `$1` with the stem and `$2` with `../LLMTuning/blogs`, producing rule text. `$(eval ...)` then injects that text into the Makefile as if you'd typed it by hand. The same pattern runs again for `assets-copy`. After this step, `make` has two new concrete rules per stem — four rules total for LLMTuning. The `md_targets += ...` and `asset_targets += ...` lines just above it append those generated targets to the global lists that `all` depends on.

**Step 4 — `make all` resolves the dependency graph.** When you run `make all`, `make` walks `$(md_targets) $(asset_targets)`. For `./_posts/2026-02-14-SMMLDev.md`, it sees the prerequisite `../LLMTuning/blogs/2026-02-14-SMMLDev.md` and the order-only `| ./_posts`. It compares mtimes: if the source in `LLMTuning/blogs/` is newer than (or the destination is missing) the file in `./_posts/`, the recipe runs. Otherwise the target is "up to date" and skipped — which is why subsequent `make all` runs are nearly instant if nothing upstream has changed.

**Step 5 — The recipe copies the file.** When the rule fires, `cp ../LLMTuning/blogs/<stem>.md ./_posts/<stem>.md` runs in the shell, importing the markdown that was originally exported from your Jupyter notebook. The asset rule, in parallel, checks whether `../LLMTuning/blogs/assets/images/<stem>/` exists — if so, it `mkdir -p`s the matching folder under `./assets/images/<stem>/` and copies the contents in; if not, it creates an empty placeholder so Jekyll doesn't choke on a missing path. Once all targets have been visited, `all` is satisfied and the Jekyll site has the freshly imported posts and images ready for the next `bundle exec jekyll build`.

The key mental model: `LLMTUNINGBlogsDir := ../LLMTuning/blogs` is a *parameter* threaded through generic templates living in the top-level Makefile, and the foreach/eval/call sandwich is what actually instantiates those templates against that parameter to produce the rules `make` ultimately executes.

### asciinema

The tool [asciinema](https://asciinema.org) records your terminal and uploads it to the cloud. You can [install](https://asciinema.org/docs/installation) this tool using `brew` in the MacOS.

## XML
Tools for XML
## Python
To setup complete python environment, see the [Python my workflow](https://ojitha.blogspot.com/2020/09/python-my-workflow.html).
To fond the python directories in the `PYTHONPATH`:

```python
import sys
import pprint from pprint
pprint(sys.path)
```

### Atom editor for Spark

First set the following path:

```bash
export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip
```

I have used SDK MAN to install the spark home.

Now create virtual environment

```bash
pyenv global 2.7.18
virtualenv mypython
source bin/activate
python -m pip install --upgrade pip
```

In the virtual enviroment, install

```bash
pip install ipykernel
```

Then run the following, if above is not working.

```bash
python -m ipykernel install --user --name=env
```

You can open it in the Atom editor and do the inline debugging if you install [Hydrogen](https://atom.io/packages/hydrogen) in the editor.

If you want to use PySpark, first install

```bash
pip install pyspark
```

To find the installed pyspark version:

```bash
pip show pyspark
```

If you want, install the following packages to Atom editor:

- Script (to execute Python from IDE, CMD+i)
- autocomplete-python
- flake 8 (to enable `pip install flake8`)
- python-autopep8

### Diff

Here is the way to semantically diff the XML files:
First, create your project in a Python virtual environment:

```bash
python3 -m venv xmltest
cd xmltest
source bin/activate
```
Your project is `xmltest`. Now install the GraphTag package
```bash
pip install graphtage
```
Now you are ready to compare m1.xml and p1.xml files:
```bash
graphtage p1.xml m1.xml
```
This will give you a out put to CLI.
to deactivate, `deactivate` in the CLI to move out from the project environment. 

### VSCode extensions for Python
Some of the extensions tested for Python:
- Use tools like flake8 and [blue](https://fpy.li/8-10). [flake8](https://fpy.li/8-9) reports on code styling, among many other issues, and blue rewrites source code according to (most) rules embedded in the [black](https://fpy.li/8-11) code formatting tool.
- isort: organise imports
- JSON Path Status Bar: Show JSON path of the element
- Output Colourizer: VSCode output in colour
- Open Folder Context Menu for VS Code: This will open a new instance of VS Code for the selected folder in the Explorer.
- Pylint: Lint from Microsoft
- 

## Spark

I have configured Spark using SDKMAN.

- [Building Spark JAR Files with SBT](https://mungingdata.com/apache-spark/building-jar-sbt/)
- [Setting up a Spark Development Environment with Scala](https://www.cloudera.com/tutorials/setting-up-a-spark-development-environment-with-scala/.html)


```bash
docker run --name pyspark -e JUPYTER_ENABLE_LAB=yes -e JUPYTER_TOKEN="pyspark"  -v "$(pwd)":/home/jovyan/work -p 8888:8888 jupyter/pyspark-notebook:d4cbf2f80a2a
```

Use the http://localhost:8888/?token=pyspark to open the jupyter notebook.

To run the Zeppelin:

```bash
docker run -u $(id -u) -p 8080:8080 -p 4040:4040 --rm -v $PWD/logs:/logs -v $PWD/:/notebook -e ZEPPELIN_LOG_DIR='/logs' -e ZEPPELIN_NOTEBOOK_DIR='/notebook' --name zeppelin apache/zeppelin:0.10.0
```

Command to create Apache Airflow

```bash
docker run -ti -p 8080:8080 -v ${PWD}/<dag>.py:/opt/airflow/dags/download_rocket_launches.py --name airflow --entrypoint=/bin/bash apache/airflow:2.0.0-python3.8 -c '( airflow db init && airflow users create --username admin --password admin --firstname Anonymous --lastname Admin --role Admin --email ojithak@gmail.com); airflow webserver & airflow scheduler'
```

## Docker Databases containers

### Postgres

Create docker image: (In the current directory, create a `data` folder)

```bash
docker run -t -i \
    --name Mastering-postgres \
    --rm \
    -p 5432:5432 \
    -e POSTGRES_PASSWORD=ojitha \
    -v "$(pwd)/data":/var/lib/postgresql/data \
    postgres:13.4
```

Docker to access psql:

```bash
docker exec -it Mastering-postgres bash
```

Inside the bash run the following command to get into the `psql`:

```bash
psql -h localhost -p 5432 -U postgres
```

### MSSQL

Pull the image

```powershell
docker pull mcr.microsoft.com/mssql/server:2019-latest
```

to run

```powershell
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Pwd@2023" `
   -p 1433:1433 --name sql1 --hostname sql1 `
   -v C:\Users\ojitha\dev\mssql\data:/var/opt/mssql/data `
   -v C:\Users\ojitha\dev\mssql\log:/var/opt/mssql/log `
   -d `
   mcr.microsoft.com/mssql/server:2019-latest
```

Download the sample database from the [backup](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms)

Run the following fix before restore

```powershell
docker container exec sql1 touch /var/opt/mssql/data/AdventureWorks2019.mdf
docker container exec sql1 touch /var/opt/mssql/log/AdventureWorks2019_log.ldf
```

## Jekylle

To start Jekylle

```bash
bundle exec jekyll serve
```

## Quarto

[Quarto](https://quarto.org) is based on [pandoc](https://pandoc.org/MANUAL.html#option--reference-doc). Here is the workflow to include a Jupyter notebook in a [Jekyll](https://jekyllrb.com/docs/posts/) site.

1. First, create a Jupyter notebook in VS Code and include the YAML in the raw form.

    ```yaml
    ---
    title: PySpark Date Example
    format:
        html:
            code-fold: true
    jupyter: python3        
    ---
    ```

    

2. now copy the `ipynb` to temp directory

3. now run the following command 

    ```bash
    quarto render pyspark_date_example.ipynb --to html
    ```

    

4. copy both of the generated folder and the html file to `<jekyll root>/_include` foler.

5. remove the `<!DOCTYPE html>` first statement from the HTML page

6. And add the post such as

    ```
    ---
    layout: post
    title:  PySpark Date Exmple
    date:   2022-03-02
    categories: [Apache Spark]
    ---
    
    PySpark date in string to date type conversion example. How you can use python sql functions like `datediff` to calculate the differences in days.
    
    <!--more-->
    
    -- include pyspark_date_example.html using liquid --
    ```

    As shown in the line# 12 embed the html file to post. 

7. Now run the Jekyll if not started

## CSVKit

Create a docker bases Postgres Docker container first. The default port is 5432.
To import CSV file to postgres test database:

```bash
csvsql --db postgresql://postgres:ojitha@localhost/test --insert data.csv
```
NOTE: Table will be created as test.public.data.

You can query the table:

```sql
SELECT * FROM test.public.data
where "invoice_no" in (....)
order by "invoice_no";
```

## Kiro

You have to select [Ubuntu](https://kiro.dev/docs/cli/installation/#ubuntu){:target="_blank"} in the [Installation - CLI - Docs - Kiro](https://kiro.dev/docs/cli/installation/){:target="_blank"} for the instructions. Briefly

to install:

```bash
wget https://desktop-release.q.us-east-1.amazonaws.com/latest/kiro-cli.deb
sudo dpkg -i kiro-cli.deb
sudo apt-get install -f
```

To [uninstall](https://kiro.dev/docs/cli/installation/#uninstalling-kiro-cli){:target="_blank"} (may be for new version)

```bash
sudo apt-get remove kiro-cli
sudo apt-get purge kiro-cli #Remove any remaining configuration files
```

