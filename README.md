# rddj-template

*A template for bootstrapping reproducible RMarkdown documents for data journalistic purposes.*

## Features

* Comes with cutting-edge, tried-and-tested packages for efficient data journalism with R, such as the `tidyverse`
* *Full* **reproducibility** with package snapshots (thanks to the `checkpoint` package)
* Runs out of the box and in one go, user doesn't have to have anything pre-installed (except R and maybe RStudio)
* Automatic deployment of knitted RMarkdown files (and zipped source code) to **GitHub pages**, see [this example](https://grssnbchr.github.io/rddj-template)
* Code **linting** according to the `tidyverse` style guide
* Preconfigured `.gitignore` which ignores shadow files, access tokens and the like per default
* Working directory is set "automagically" (thanks to [@fin](https://github.com/fin))

*For more information please see the [accompanying blog post](https://timogrossenbacher.ch/2017/07/a-truly-reproducible-r-workflow/)*.

## Setup

First, clone and *reset* git repository.

```
git clone https://github.com/grssnbchr/rddj-template.git
cd rddj-template
rm -rf .git
git init
```

If you have a remote repository, you can add it like so: 

```
git remote add origin https://github.com/user/repo.git
```

## How to run

0. The main document `main.Rmd` lies in the folder `analysis`. This is where most of your code resides.

1. Set config variables in the very first chunk, specifically:
  * `package_date`: This is the historical date of CRAN packages you want to use. Usually, you set this to the current date and leave it be. This way, further executions of the script will always use packages from this very date, ensuring reproducibility.
  * `R_version`: While specifying a package date is the first step for true reproducibility, you also need to tell people what R version you were using, for the sake of compatibility. For instance, R version 3.5.x probably won't work with packages released before May/June 2018. People who want to reproduce a script that you wrote in 2017, for instance, will have to install R version 3.4.x in order to ensure reproducibility. 
  * `options(Ncpus = x)`: People with multi-core machines can get a performance boost by specifying more than one core here. If you don't know the number of cores on your machine, set `x` to `1`.

2. **Run the script**: The individual R chunks should be run in the interpreter (`Code > Run Region > Run All`) on Linux/Windows: <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>R</kbd>, on Mac: <kbd>Cmd</kbd>+<kbd>Alt</kbd>+<kbd>R</kbd>). Be advised that some packages, like `rgdal`, need additional third party libraries installed. Watch out for compiler/installation messages in the R console. On a Mac, occasional `y/n:` prompts may show up in the R console during package installation (section "install packages") – just confirm them by pressing `y` and <kbd>Enter</kbd>.  Knitting the RMarkdown should *not* be done with RStudio (see below).

**WARNING**: It is recommended to restart R (`Session > Restart R`) when starting from scratch, i.e. use `Session > Restart R and Run All Chunks` instead of `Run All Chunks`. If you don't do that, `checkpoint` will be re-installed in your local `.checkpoint` folder, or other errors might occur. 

3. **Knitting the RMarkdown**: Because of how RStudio and `checkpoint` works, the use of the "knit" functionality in RStudio is *strongly discouraged*. It might work, but the preferred way is using the `knit.sh` shell script, execute it in a terminal like so: `./knit.sh`. This will make sure the `rmarkdown` package from the specified package date will be used, not the globally installed one. `knit.sh` knits the script into a html document `analysis/main.html`. If you get an error saying that Pandoc could not be found, you need to let your terminal know where the `pandoc` binary resides by adjusting the `PATH` variable. This holds true for both Linux and Mac OS. Pandoc comes with RStudio, and the binary usually resides in `/usr/lib/rstudio/bin` and `/Applications/RStudio.app/Contents/MacOS/pandoc` respectively. So add the respective directory to your path. Workaround without setting the `PATH` variable: Executing `knit.sh` in the built in RStudio terminal (*not* the R console!) always works because RStudio obviously knows the location of the Pandoc binary. *Knitting to PDF is currently not supported*.

## Branches

There are three branches at the moment:

* master: Uses R 3.5.x and packages as of 2018-09-01
* r-3.4: Uses R 3.4.4 and packages as of 2018-04-01
* r-3.3: Uses R 3.3.3 and packages as of 2017-01-01

Use whichever you want. 

## OS support

Last tested November 2018. 

☑️: Full functionality (including knitting RMarkdown with `knit.sh`)

(☑️): Limited functionality (without `knit.sh`)

| branch           | Ubuntu 16.04 | Ubuntu 18.04 | macOS High Sierra | macOS Mojave | Windows 10 |
|------------------|--------------|--------------|-------------------|--------------|------------|
| master (R-3.5.x) |              | ☑️            | ☑️                 | ☑️             | (☑️)        |
| R-3.4.x          | ☑️            | ☑️            | ☑️                 | ☑️            | (☑️)            |
| R-3.3.x          |              | ☑️<sup>1</sup>| ☑️                   |☑️<sup>3</sup>              |(☑️)<sup>2</sup>           |

* <sup>1</sup>: It may be necessary to reinstall the `curl` package because of `libcurl`. See https://github.com/grssnbchr/rddj-template/issues/9. Also, the compilation of `rgdal` [fails with GDAL 2.2.x](https://github.com/grssnbchr/rddj-template/issues/10).
* <sup>2</sup>: On my setup, `devtools` could not be installed in one go. First I had to install [RTools](https://cran.r-project.org/bin/windows/Rtools/). Then I had to manually `install.packages("debugme"); install.packages("pkgload"); install.packages("pkgbuild"); install.packages("devtools")`, and then it would finally install `checkpoint` and work smoothly from there. If you encounter any errors while installing `devtools`, have a close look at them and try to figure out what dependencies are missing, then install them manually. 
* <sup>3</sup>There were errors similar to <sup>2</sup>. When prompted to choose between binary and source packages, I always typed in "y" and hit Enter. This way it worked for me.

## More about `checkpoint`

This template uses the [`checkpoint` package by Microsoft](https://mran.microsoft.com/documents/rro/reproducibility/#timemachine) for full package reproducibility. With this package, all necessary packages (specified in the `Define packages` R chunk) are from a certain CRAN snapshot which you can specify in the very same R chunk (`package_date`). For each `package_date`, the necessary source and compiled packages will be installed to a local `.checkpoint` folder that resides in your home directory. 

This has two big advantages:

1. All packages are from the same CRAN snapshot, i.e. are supposed to play nicely together.
2. If you re-run your script two or three years after initial creation, exactly those packages that were used at that point in time, that work with *your* code you wrote back then, are loaded and executed. No more deprecated code pieces and weird-looking `ggplot2` plots!

In order to make `checkpoint` work with `knitr`, [this vignette](https://github.com/RevolutionAnalytics/checkpoint/blob/master/vignettes/archive/using-checkpoint-with-knitr.Rmd) was adapted (it is now archived).

### The downside(s) of `checkpoint`

With `checkpoint`, you can only access archived packages from CRAN, i.e. MRAN. As others [have pointed out](https://timogrossenbacher.ch/2017/07/a-truly-reproducible-r-workflow/#comment-48928), GitHub repositories don't fit into this system. I wouldn't consider this as a big issue as you can install specific versions (i.e. releases/tags) from GitHub and as long as the GitHub repository stays alive, you can access these old versions. This is how the `checkpoint` package itself is installed in this template, by the way: 

```
devtools::install_github("checkpoint",
                           username = "RevolutionAnalytics",
                           ref = "v0.3.2")
```

A second possible disadvantage is the reliance on Microsoft's snapshot system. Once these snapshots are down, the whole system is futile. I reckon/hope there will be third party mirrors though once the system gets really popular. Update September 2017: Apparently you can roll your [own checkpoint server](https://github.com/RevolutionAnalytics/checkpoint-server). 

## Deployment to GitHub pages

The knitted RMarkdown may be deployed to a respective GitHub page. If your repository `repo` is public, it can then be accessed via `https://user.github.io/repo` (example: https://grssnbchr.github.io/rddj-template). In order to do that,

1. Make sure there **are no unstaged changes** in your working directory. Either `git commit` them or `git stash` them before continuing. 

2. Make sure you're in the root folder of your project (the one above `analysis`)

3. Then locally create a `gh-pages` branch first, checkout master again and run the `deploy.sh` script in the root folder:

```
git checkout -b gh-pages
git checkout master
./deploy.sh
```

4. For further deployments, it is sufficient to re-run `./deploy.sh`. Make sure your working directory is clean before that step. If that is not the case, deployment will not work.

`deploy.sh` does the following: 

* Knit `main.Rmd` into `main.html` using `pandoc`. If that does not work, modify your `PATH` variable like so:
`export PATH="$PATH:/usr/lib/rstudio/bin/pandoc"` (tested on Linux). 
* Turn `main.html` into `index.html` so it can be rendered by GitHub pages.
* Bundle `main.Rmd`, `input`, `output` and `scripts` into a zipped folder `rscript.zip` so the repo can be easily downloaded by people who don't understand Git.
* Push everything to your remote `gh-pages` branch (will be created if not existing). 
* GitHub now builds the page and it should soon be accessible via `https://user.github.io/repo`.

## Linting / styleguide

Code is automatically *linted* with `lintr`, i.e. checked for good style and syntax errors according to the [tidyverse style guide](http://style.tidyverse.org/). When being knitted, the `lintr` output is at the very end of the document. When being interpreted, the `lintr` output appears in a new `Markers` pane at the bottom of RStudio. If you want to disable linting, just comment that last line in `main.Rmd` out.

## Other stuff / more features

### Versioning of input and output

`input` and `output` files are not ignored by default. This has the advantage that output can be monitored for change when (subtle) details of the R code are changed. 

If you want to ignore (big) input or output files, put them into the respective `ignore` folders. GitHub only allows a maximum file size of 100MB as of summer 2017.

### Ability to outsource code to script files

If you want to keep your `main.Rmd` as tidy and brief as possible, you have the possibility to put separate functions and other code into script files that reside in the `scripts` folder. An example of this is provided in `main.Rmd`.

### Multiple CPU cores for faster package installation

By default, more than one core is used for package installation, which significantly speeds up the process.

### Optimal RStudio settings

It is recommended to disable workspace saving in RStudio, see  https://mran.microsoft.com/documents/rro/reproducibility/doc-research/ 


## Installation of older R versions

The idea of this template is that you specify your currently used R version, and that people trying to reproduce your scripts will use that very same R version (or at least up to the two first version numbers, e.g. 3.4.x). This makes it necessary to install old R versions. Here's some advice on how to do that on a couple of OSes. 

### Debian (tested on Ubuntu 16.04 and higher)

Compiled with information from [here](http://r.789695.n4.nabble.com/Installing-different-versions-of-R-simultaneously-on-Linux-td879536.html), [here](https://cloud.r-project.org/doc/FAQ/R-FAQ.html#How-can-R-be-installed-_0028Unix_002dlike_0029) and [here](http://spartanideas.msu.edu/2015/06/19/alternative-versions-of-r/).

* Download the required archive from [here](https://cloud.r-project.org/src/base/)
* Untar and move it to the `/opt/src` directory with `sudo tar -xvf R-x.y.z.tar.gz -C /opt/src`, this will create a new directory
* Change into that new directory and run `sudo ./configure --enable-R-shlib --with-cairo=yes --prefix=/opt/R/R-x.y.z` (**change placeholders!**)
* Install some graphics dependencies `sudo apt-get install libcairo2-dev libgtk2.0-dev libtiff5-dev libx11-dev` if not already done.
* Compile it with `sudo make`
* Optionally run `sudo make check`
* Install it with `sudo make install`
* There should be an executable binary in `/opt/R/R-x.y.z/bin` now.
* In order to let your system know of that new R version and to be able to switch between alternatives, do this:
  * Run `update-alternatives --list R` to see whether R is already registered with alternative versions
  * If not, make a default alternative `sudo rm -rf /usr/bin/R && sudo update-alternatives --install /usr/bin/R R /usr/lib/R/bin/R 1000` (this is probably the newest R version from the Debian package management system)
  * Add the newly installed R version as alternative `sudo update-alternatives --install /usr/bin/R R /opt/R/R-x.y.z/bin/R 100`
  * Check with `update-alternatives --display R`.
  * From now on, you can easily switch between R versions doing `sudo update-alternatives --config R`. Do this before you start RStudio (RStudio always uses the symlink in `/usr/bin/R`).
  * If the `update-alternatives` switch does not work for some reason, manually set a link with `sudo ln -sf /opt/R/R-x.y.z/bin/R /usr/bin/R` to switch to version `x.y.z`.
  
### macOS X (tested on High Sierra and higher)

* First of all, you need to have at least one R version installed (probably the latest one).
* Navigate to r.research.att.com and download/install the so-called [RSwitch GUI](http://r.research.att.com/RSwitch-1.2.dmg).
* Download the patched versions of the branch you want to install (earliest available branch is 3.3.) under [this section](http://r.research.att.com/#nightly).
* Extract the downloaded `*.tar.gz` file and move the folder `Library/Frameworks/R.framework/Versions/x.y` to `/Library/Frameworks/R.framework/Versions/`.
* Launch "RSwitch GUI" and switch between R versions (change is effective immediately, no need to restart RStudio, only R).

### Windows 10

* Install all desired R binaries directly from [r-project.org](https://cloud.r-project.org/bin/windows/base/old/).
* RStudio (tested with 1.1.463) has a very convenient switch for R versions that can be found under *Tools > Global Options > General > R version*. After switching, restart RStudio. 
  
