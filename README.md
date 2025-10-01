# nbltools
Diffusion MRI preprocessing pipeline with denoising, distortion correction, and quality control.

### Running the preprocessing pipeline with Docker

Build the docker image:
```docker buildx build -t nbltools .```

Run the docker container interactively:
```docker run -v <your-data-dir>:/data -it nbltools bash```

Then run ```run_all_tu``` from inside the docker container to see the usage documentation.
