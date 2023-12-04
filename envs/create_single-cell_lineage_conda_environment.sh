# Set up a conda environment for single-cell_lineage work

env_name="single-cell_lineage"

mamba env create -f environment.yml || conda env create -f environment.yml

