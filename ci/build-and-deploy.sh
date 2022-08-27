#!/bin/bash

set -xe

# Install npm and antora
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs
npm -v
npm i -g @antora/cli@3.0.1
npm i -g @antora/site-generator@3.0.1
antora -v

# Update dependencies and build site
antora site.yml
touch docs/.nojekyll

# Set up a git environment in docs
orig_subject=$(git log -1 --oneline $FETCH_HEAD)
author_email=$(git log -1 --pretty=format:"%ae")
cd docs
git init -b gh-pages
git remote add origin \
    https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY
git config --local user.email "$author_email"
git config --local user.name "$GITHUB_ACTOR"

# Commit changes and push to gh-pages
git add --all .
git fetch origin $GITHUB_SHA
msg="[CI] Updating gh-pages branch from ${GITHUB_SHA:0:8}"
if [[ "$orig_subject" == *full?linkcheck* ]]; then
    msg="[full-linkcheck] $msg"
fi
git commit -q -m "$msg"
git push -f origin gh-pages:gh-pages

git checkout gh-pages
git checkout build -- ./manuals
git push -f
git commit -m "add globe"
git push
