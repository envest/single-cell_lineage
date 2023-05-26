# Set up a conda environment for single-cell_lineage work

env_name="single-cell_lineage"

conda create -n $env_name python=3.6 anaconda

# you may need to initialize conda and source your .bashrc or .bash_profile (etc.) or restart the shell
#conda init [your shell]

# install pysam https://pysam.readthedocs.io/en/latest/
# pysam packages requires python 3.6 or below
conda install -n $env_name -c bioconda pysam

# install pyVCF https://pyvcf.readthedocs.io/en/latest/
conda install -n $env_name -c bioconda pyvcf

# install samtools and bcftools https://samtools.github.io/bcftools/
conda install -n $env_name -c bioconda samtools=1.9
conda install -n $env_name -c bioconda bcftools

# install R v4.3.0 and renv package
conda install -n $env_name -c conda-forge r-base=4.3.0
conda install -n $env_name -c conda_forge r-renv

# at start of each session, to activate the environment
conda activate $env_name

# to exit the environment, close your terminal, or 
#conda deactivate

# to delete the environment
#conda remove -n SomaticHaplotype --all

