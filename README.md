# NBLtools

Diffusion MRI preprocessing pipeline developed by the [Neuroimaging & Biophysics Lab (NBL)](https://nbl-research.github.io).

## Overview

NBLtools automates the key preprocessing steps for diffusion MRI data:

- Denoising (TORTOISE)
- Gibbs ringing correction
- SynB0-DISCO synthetic reverse phase-encode generation (when no reverse blip data is available)
- Topup susceptibility-induced distortion correction
- Optibet robust brain masking
- Eddy current and motion correction (CPU and GPU/CUDA)
- Quality control reporting

For detailed installation instructions, data organization, and usage documentation, visit the [NBLtools website](https://nbl-research.github.io/nbltools.html).

## Quick Start

### Native installation

```bash
# With reverse phase-encode data:
run_all_tu ./subject01 -f -p -b 1 -i -t -m -e -c 0 -q

# With SynB0-DISCO (no reverse phase-encode data):
run_all_tu ./subject01 -f -y -p -t -m -e -c 0 -q
```

Run `run_all_tu` without arguments to see all available options.

### Docker

Pull the pre-built image:

```bash
docker pull ghcr.io/nbl-research/nbltools:latest
```

Create a launch script (e.g. `run_nbltools.sh`):

```bash
#!/bin/bash
docker run -it \
  -v /path/to/your/data:/data \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /path/to/freesurfer:/freesurfer \
  -e HOST_DATA=/path/to/your/data \
  -e HOST_FREESURFER=/path/to/freesurfer \
  -e FREESURFER=/freesurfer \
  ghcr.io/nbl-research/nbltools bash
```

Replace the paths with your actual data directory and FreeSurfer license location. The Docker socket and FreeSurfer mounts are only needed for SynB0-DISCO (`-y` flag).

### Building the Docker image

To build from source:

```bash
git clone https://github.com/nbl-research/nbltools.git
cd nbltools
docker build -t nbltools .
```

## Support

- [Documentation](https://nbl-research.github.io/nbltools.html)
- [Issue tracker](https://github.com/nbl-research/nbltools/issues)
- Email: info.nblresearch@gmail.com
