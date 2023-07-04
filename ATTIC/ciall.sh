#!/bin/bash
for file in *.ME *.pl *.sql *.sh *.dtd; do ci -l $file; done
