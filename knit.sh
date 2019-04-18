#!/bin/bash
# knit
# add >>>export PATH="$PATH:/usr/lib/rstudio/bin/pandoc"<<< to your PATH in order for knitting to work

# first, find out OS
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

# terminate if neither Linux nor Mac
if [ "$machine" != "Linux" -a "$machine" != "Mac" ]; then
  echo "ERROR: Your OS is not supported, terminating."
  exit 1
fi

# find out checkpoint package date from main.Rmd
package_date_raw="$(grep -E "package_date\s<-\s\"[0-9]{4}\-[0-9]{2}\-[0-9]{2}\"" analysis/main.Rmd -o)"
# version_raw="$(grep -E "R_version\s<-\s\"[0-9]{1}\.[0-9]{1}\.[0-9]{1}\"" analysis/main.Rmd -o)"
# extract substring for date
package_date=${package_date_raw:16}

# find out system variables
platform="$(R -e "version[[\"platform\"]]" -q)"
r_version="$(R -e "paste0(version[[\"major\"]], \".\", version[[\"minor\"]])" -q)"
# remove leading [1]
platform=$(echo "$platform" | grep -Eio "\[1\]\s(\".+\")" | cut -d " " -f 2)
r_version=$(echo "$r_version" | grep -Eio "\[1\]\s(\".+\")" | cut -d " " -f 2)
# build up path
r_lib_path="~/.checkpoint/$package_date/lib/$platform/$r_version/"
# remove "
r_lib_path=${r_lib_path//\"/}

echo "setting $r_lib_path as R_LIBS"
# set correct checkpoint folder, so main.Rmd is knitted with historical rmarkdown package
export R_LIBS_USER=${r_lib_path}
# env variable RSTUDIO has to be unset when running knit.sh in the built-in RStudio terminal
R -e 'Sys.unsetenv("RSTUDIO"); library(rmarkdown); rmarkdown::render("analysis/main.Rmd", "html_document")' --no-site-file --no-init-file --no-restore --no-save || { echo "ERROR: knitting failed."; exit 1; }

# open browser
# TODO should probably be adapted for Mac OS
# xdg-open analysis/main.html
