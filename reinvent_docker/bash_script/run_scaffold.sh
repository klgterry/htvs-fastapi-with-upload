#!/bin/bash
export PATH="/root/anaconda3/bin:$PATH"

rm -f /curate/denovo/*
rm -f /curate/molopt/*
rm -f /curate/linker/*
rm -f /curate/scaffold/*

eval "$(conda shell.bash hook)"
conda activate reinvent4

reinvent -l curate/scaffold/success.log curate/input/scaffold.toml
