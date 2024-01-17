# # Dockerfile for base image for the API
# FROM ubuntu:22.04

# # Setup environment to match variables set by repo2docker as much as possible
# # The name of the conda environment into which the requested packages are installed
# ENV CONDA_ENV=api \
#     # Tell apt-get to not block installs by asking for interactive human input
#     DEBIAN_FRONTEND=noninteractive \
#     # Set username, uid and gid (same as uid) of non-root user the container will be run as
#     NB_USER=tosca \
#     NB_UID=1000 \
#     # Use /bin/bash as shell, not the default /bin/sh (arrow keys, etc don't work then)
#     SHELL=/bin/bash \
#     # Setup locale to be UTF-8, avoiding gnarly hard to debug encoding errors
#     LANG=C.UTF-8  \
#     LC_ALL=C.UTF-8 \
#     # Install conda in the same place repo2docker does
#     CONDA_DIR=/srv/conda \
#     CONDA_LOCK_FILE=conda-lock.yml\
#     PYTHON_VERSION=3.10

# # All env vars that reference other env vars need to be in their own ENV block
# # Path to the python environment where the jupyter notebook packages are installed
# ENV NB_PYTHON_PREFIX=${CONDA_DIR}/envs/${CONDA_ENV} \
#     # Home directory of our non-root user
#     HOME=/home/${NB_USER}

# WORKDIR ${HOME}/installation
# # Add both our notebook env as well as default conda installation to $PATH
# # Thus, when we start a `python` process (for kernels, or notebooks, etc),
# # it loads the python in the notebook conda environment, as that comes
# # first here.
# ENV PATH=${NB_PYTHON_PREFIX}/bin:${CONDA_DIR}/bin:${PATH}

# # Ask dask to read config from ${CONDA_DIR}/etc rather than
# # the default of /etc, since the non-root jovyan user can write
# # to ${CONDA_DIR}/etc but not to /etc
# ENV DASK_ROOT_CONFIG=${CONDA_DIR}/etc

# RUN echo "Creating ${NB_USER} user..." \
#     # Create a group for the user to be part of, with gid same as uid
#     && groupadd --gid ${NB_UID} ${NB_USER}  \
#     # Create non-root user, with given gid, uid and create $HOME
#     && useradd --create-home --gid ${NB_UID} --no-log-init --uid ${NB_UID} ${NB_USER} \
#     # Make sure that /srv is owned by non-root user, so we can install things there
#     && chown -R ${NB_USER}:${NB_USER} /srv


# # Install basic apt packages
# RUN echo "Installing Apt-get packages..." \
#     && apt-get update --fix-missing > /dev/null \
#     && apt-get install -y apt-utils wget zip tzdata > /dev/null \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*
# # Add TZ configuration - https://github.com/PrefectHQ/prefect/issues/3061
# ENV TZ UTC
# # ========================
# # Install latest mambaforge in ${CONDA_DIR}
# RUN echo "Installing Mambaforge..." \
#     && URL="https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh" \
#     && wget --quiet ${URL} -O installer.sh \
#     && /bin/bash installer.sh -u -b -p ${CONDA_DIR} \
#     && rm installer.sh \
#     && mamba install conda-lock -y \
#     && mamba clean -afy \
#     # After installing the packages, we cleanup some unnecessary files
#     # to try reduce image size - see https://jcristharif.com/conda-docker-tips.html
#     # Although we explicitly do *not* delete .pyc files, as that seems to slow down startup
#     # quite a bit unfortunately - see https://github.com/2i2c-org/infrastructure/issues/2047
#     && find ${CONDA_DIR} -follow -type f -name '*.a' -delete

# COPY ./*yml ./*.toml ./*.lock ${HOME}/installation/

# # RUN conda create --name ${CONDA_ENV}  --no-default-packages 

# # RUN conda env create -f environment.yml
# # RUN echo ". ${CONDA_DIR}/etc/profile.d/conda.sh ; conda activate ${CONDA_ENV}" > /etc/profile.d/init_conda.sh
# # # Override default shell and use bash
# # SHELL ["conda", "run", "-n", "env", "/bin/bash", "-c"]

# # Check for conda-lock.yml or environment.yml
# RUN if [ -f "environment.yml" ]; then \
#         conda env create -f environment.yml; \
#     else \
#         conda create -n ${CONDA_ENV} python=${PYTHON_VERSION} mamba pip conda-lock poetry==1.3.1; \
#     fi && \
#     conda clean -yaf \
#     && find /srv/conda -follow -type f -name '*.a' -delete \
#     && mamba clean -yaf \
#     && find ${CONDA_DIR} -follow -type f -name '*.a' -delete \
#     && find ${CONDA_DIR} -follow -type f -name '*.js.map' -delete

# RUN echo ". ${CONDA_DIR}/etc/profile.d/conda.sh ; conda activate ${CONDA_ENV}" > /etc/profile.d/init_conda.sh

# # If a pyproject.toml file exists, use poetry to install packages listed there.
#  RUN echo "Checking for Poetry 'pyproject.toml'..." \
#     && if test -f "pyproject.toml" ; then \
#         ${NB_PYTHON_PREFIX}/bin/poetry install \
#     ; fi \
#     && echo "Done installing Conda and Poetry" \
# SHELL ["conda", "run", "-n", "env", "/bin/bash", "-c"]
# # Remove .yml, .toml ve .lock 
# # RUN rm -f ./*.yml ./*.toml ./*.lock
# # docker run --rm -it -e SHELL=/bin/bash -e LANG=C.UTF-8 -e LC_ALL=C.UTF-8 -v /home/ortak/Desktop/HCU/PythonBaseContainer/python-base-container:/home/jovyan/installation test-silinecek bash
######################################
# Dockerfile for base image of all pangeo images
FROM ubuntu:22.04
# build file for pangeo images

LABEL org.opencontainers.image.source=https://github.com/pangeo-data/pangeo-docker-images

# Setup environment to match variables set by repo2docker as much as possible
# The name of the conda environment into which the requested packages are installed
ENV CONDA_ENV=api \
    # Tell apt-get to not block installs by asking for interactive human input
    DEBIAN_FRONTEND=noninteractive \
    # Set username, uid and gid (same as uid) of non-root user the container will be run as
    NB_USER=tosca \
    NB_UID=1000 \
    # Use /bin/bash as shell, not the default /bin/sh (arrow keys, etc don't work then)
    SHELL=/bin/bash \
    # Setup locale to be UTF-8, avoiding gnarly hard to debug encoding errors
    LANG=C.UTF-8  \
    LC_ALL=C.UTF-8 \
    # Install conda in the same place repo2docker does
    CONDA_DIR=/srv/conda \
    CONDA_LOCK_FILE=conda-lock.yml\
    PYTHON_VERSION=3.10

# All env vars that reference other env vars need to be in their own ENV block
# Path to the python environment where the jupyter notebook packages are installed
ENV NB_PYTHON_PREFIX=${CONDA_DIR}/envs/${CONDA_ENV} \
    # Home directory of our non-root user
    HOME=/home/${NB_USER}

# Add both our notebook env as well as default conda installation to $PATH
# Thus, when we start a `python` process (for kernels, or notebooks, etc),
# it loads the python in the notebook conda environment, as that comes
# first here.
ENV PATH=${NB_PYTHON_PREFIX}/bin:${CONDA_DIR}/bin:${PATH}

# Ask dask to read config from ${CONDA_DIR}/etc rather than
# the default of /etc, since the non-root jovyan user can write
# to ${CONDA_DIR}/etc but not to /etc
ENV DASK_ROOT_CONFIG=${CONDA_DIR}/etc

RUN echo "Creating ${NB_USER} user..." \
    # Create a group for the user to be part of, with gid same as uid
    && groupadd --gid ${NB_UID} ${NB_USER}  \
    # Create non-root user, with given gid, uid and create $HOME
    && useradd --create-home --gid ${NB_UID} --no-log-init --uid ${NB_UID} ${NB_USER} \
    # Make sure that /srv is owned by non-root user, so we can install things there
    && chown -R ${NB_USER}:${NB_USER} /srv

# Run conda activate each time a bash shell starts, so users don't have to manually type conda activate
# Note this is only read by shell, but not by the jupyter notebook - that relies
# on us starting the correct `python` process, which we do by adding the notebook conda environment's
# bin to PATH earlier ($NB_PYTHON_PREFIX/bin)
RUN echo ". ${CONDA_DIR}/etc/profile.d/conda.sh ; conda activate ${CONDA_ENV}" > /etc/profile.d/init_conda.sh

# Install basic apt packages
RUN echo "Installing Apt-get packages..." \
    && apt-get update --fix-missing > /dev/null \
    && apt-get install -y apt-utils wget zip tzdata > /dev/null \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# Add TZ configuration - https://github.com/PrefectHQ/prefect/issues/3061
ENV TZ UTC
# ========================

# Install latest mambaforge in ${CONDA_DIR}
RUN echo "Installing Mambaforge..." \
    && URL="https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh" \
    && wget --quiet ${URL} -O installer.sh \
    && /bin/bash installer.sh -u -b -p ${CONDA_DIR} \
    && rm installer.sh \
    && mamba install conda-lock -y \
    && mamba clean -afy \
    # After installing the packages, we cleanup some unnecessary files
    # to try reduce image size - see https://jcristharif.com/conda-docker-tips.html
    # Although we explicitly do *not* delete .pyc files, as that seems to slow down startup
    # quite a bit unfortunately - see https://github.com/2i2c-org/infrastructure/issues/2047
    && find ${CONDA_DIR} -follow -type f -name '*.a' -delete
    #conda create -p conda-pkg.yaml -c conda-forge mamba conda-lock poetry='1.3'
WORKDIR /home/tosca/installation/
# Copy importan files for installation
COPY ./*yml ./*.toml ./*.lock ${HOME}/installation/
# -----------------------------------------------------------------------------------------------
# # Check for conda-lock.yml or environment.yml
RUN if [ -s "conda-lock.yml" ]; then \
        echo "Running command for conda-lock"; \
        conda-lock install --name ${CONDA_ENV} ${CONDA_LOCK_FILE}; \
    elif [ -s "environment.yml" ]; then \
        echo "Running command for environment.yml"; \
        conda env create -f environment.yml --name ${CONDA_ENV} --no-default-packages  \
    else \
        echo "Conda env is created by system with default ${PYTHON_VERSION}}, mamba,pip and poetry"; \
        conda create -n ${CONDA_ENV} python=${PYTHON_VERSION} mamba pip conda-lock poetry==1.3.1; \
    fi && \
    conda clean -yaf \
    && find /srv/conda -follow -type f -name '*.a' -delete \
    && mamba clean -yaf \
    && find ${CONDA_DIR} -follow -type f -name '*.a' -delete \
    && find ${CONDA_DIR} -follow -type f -name '*.js.map' -delete
# -----------------------------------------------------------------------------------------------
# If a pyproject.toml file exists, use poetry to install packages listed there.
RUN echo "Checking for Poetry 'pyproject.toml'..." \
    && poetry config virtualenvs.create false \
    && if test -f "pyproject.toml" ; then \
        ${NB_PYTHON_PREFIX}/bin/poetry install; \
        echo "Done installing Conda and Poetry"; \
    else \
        echo "No pyproject.toml found! *Initializing a new Poetry environment*"; \
    fi
RUN rm  ./*yml ./*.toml ./*.lock 