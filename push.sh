#!/bin/bash
git add .
git commit -m "Auto sync: $(date '+%Y-%m-%d %H:%M:%S')"
git push
echo "Da day code len GitHub thanh cong!"
