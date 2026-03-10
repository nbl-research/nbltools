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
           vim \
           gnupg \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

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
RUN conda install -y --name base -c $FSL_CONDA_CHANNEL fsl-avwutils fsl-bet2 fsl-eddy fsl-eddy_qc fsl-topup fsl-miscvis -c conda-forge
ENV FSLDIR="/opt/miniforge"
RUN echo ". ${FSLDIR}/etc/fslconf/fsl.sh" >> ~/.bashrc

# Install TORTOISE
RUN wget https://github.com/QMICodeBase/TORTOISEV4/releases/download/4.1.0/TORTOISEV41_package_090425.tar.gz
RUN tar -xf TORTOISEV41_package_090425.tar.gz -C /opt
RUN rm TORTOISEV41_package_090425.tar.gz
RUN mv /opt/TORTOISEV41_package_090425 /opt/TORTOISE
ENV PATH="/opt/TORTOISE/bin:$PATH"

# Install dcm2niix
RUN conda install -y -c conda-forge dcm2niix

ENV NBL_EDDY_DEFAULT=0

RUN mkdir -p /opt/nbl/preprocessing /opt/nbl/data/REF
ADD preprocessing /opt/nbl/preprocessing/
COPY data/REF/BRCATLASC_B0_TEMPLATE_2MM /opt/nbl/data/REF/BRCATLASC_B0_TEMPLATE_2MM
ENV PATH="/opt/nbl/preprocessing:$PATH"

RUN mkdir /data
RUN chmod a+rwx /data
WORKDIR /data
