FROM ubuntu:jammy

# Update and install required packages
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           ca-certificates \
           curl \
           unzip \
		   wget \
		   bzip2 \
		   bc \
		   vim

RUN rm -rf /var/lib/apt/lists/*

# Install ANTs
RUN curl -fsSL -o ants.zip https://github.com/ANTsX/ANTs/releases/download/v2.5.2/ants-2.5.2-ubuntu-22.04-X64-gcc.zip

RUN unzip ants.zip -d /opt \
    && rm ants.zip

ENV ANTSPATH="/opt/ants-2.5.2/bin" \
    PATH="/opt/ants-2.5.2/bin:$PATH"

# Install miniforge (conda-forge based) instead of miniconda
RUN export PATH="/opt/miniforge/bin:$PATH" \
    && conda_installer="/tmp/miniforge.sh" \
    && curl -fsSL -o "$conda_installer" https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh \
    && bash "$conda_installer" -b -p /opt/miniforge \
    && rm -f "$conda_installer" \
    && export PATH="/opt/miniforge/bin:$PATH" \
    && conda config --set channel_priority strict \
    && conda config --system --set auto_update_conda false \
    && conda config --system --set show_channel_urls true \
    # Enable `conda activate`
    && conda init bash \
    # Clean up
    && sync && conda clean --all --yes && sync \
    && rm -rf ~/.cache/pip/*

# Update PATH to use miniforge
ENV PATH="/opt/miniforge/bin:$PATH"

# Install FSL packages using conda
ENV FSL_CONDA_CHANNEL="https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/public"
RUN conda install -y --name base -c $FSL_CONDA_CHANNEL fsl-avwutils fsl-bet2 fsl-eddy fsl-eddy_qc fsl-topup -c conda-forge
ENV FSLDIR="/opt/miniconda-latest"
RUN echo ". ${FSLDIR}/etc/fslconf/fsl.sh" >> ~/.bashrc
ENV OMP_NUM_THREADS=4

# Install TORTOISE
RUN wget https://github.com/eurotomania/TORTOISEV4/releases/download/beta_rc.2.0.0/TORTOISE_package.tar.gz
RUN tar -xf TORTOISE_package.tar.gz -C /opt
RUN rm TORTOISE_package.tar.gz
RUN mv /opt/TORTOISE_package /opt/TORTOISE
ENV PATH="/opt/TORTOISE/bin:$PATH"

# Install dcm2niix
RUN conda install -y -c conda-forge dcm2niix

RUN mkdir /opt/nbl
ADD scripts /opt/nbl/
#COPY run_all /opt/nbl/
#COPY run_all_tu /opt/nbl/
#COPY prepare_4_topup /opt/nbl/
#COPY run_fda_preproc /opt/nbl/
#COPY run_eddy /opt/nbl/
#COPY run_topup /opt/nbl/
#COPY check_bvecs /opt/nbl/
#COPY prepeddyindex /opt/nbl/
#COPY nbl_register_brain_using_ants /opt/nbl/
#COPY nbl_optibet_b0_ants /opt/nbl/
#COPY nbl_intensity_scaling /opt/nbl/
RUN mkdir -p /opt/nbl/data/REF
COPY BRCATLASC_B0_TEMPLATE_2MM /opt/nbl/data/REF/BRCATLASC_B0_TEMPLATE_2MM
ENV PATH="/opt/nbl:$PATH"

RUN mkdir /data
RUN chmod a+rwx /data
WORKDIR /data
