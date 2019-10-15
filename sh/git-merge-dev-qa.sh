#!/usr/bin/env bash

git checkout development && \
git pull && \
git checkout qa && \
git pull && \
git merge development -m 'merge development into qa' && \
git push
