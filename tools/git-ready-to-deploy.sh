#!/usr/bin/env bash

# This file was generated from an m4 template.
# Generation date-time (ISO 8601): 2018-06-22T10:10+00:00
# Git repository URL: https://github.com/oleks/git-ready-to-deploy
# Commit ID: 394c2b040558a890d33d996c402d6594d1e5dfc6

# Copyright (c) 2016-2018 Oleks <oleks@oleks.info>
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

set -euo pipefail

failcode=1

nlines=$(git status . --porcelain | wc -l)
if [ ${nlines} -ne 0 ] ; then
  cat <<EOF
#####################################################
# Nice! You have changes. Now commit or stash them. #
#####################################################
EOF
  git status .
  exit ${failcode}
fi

echo "Let me check your remote.."
git remote update

nlines=$(git cherry | (grep "^+" || true) | wc -l)
if [ ${nlines} -ne 0 ] ; then
  cat <<EOF
#####################################
# Nice! You have commits. Now push. #
#####################################
EOF
  git status .
  exit ${failcode}
fi

echo "Looks like you are up-to-date."
