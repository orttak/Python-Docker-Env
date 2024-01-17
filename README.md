# Python & Docker Base Environment For New Projects

Create a base environment with Python 3.10, conda, mamba, pip, conda-lock, and poetry==1.3.1. This structure allows manipulation of the Docker environment based on the project's needs.

- Dockerfile
- environment.yml
- conda-lock.yml # This file will be empty when base image files are first pulled. It should be created by the admin after creating the environment.
- pyproject.toml

In this structure, while managing libraries with poetry, problematic ones with pip can be added via conda. The versions of used libraries can be pinned with conda-lock.

Add a library to poetry.lock with `poetry add --lock library_name`. This automatically updates the poetry.toml file.

If a library is installed with conda, its version is added to the environment.yml file. Then, the conda-lock.yml file is updated with:

`conda-lock -f environment.yml --lockfile conda-lock.yml`

Both conda-lock.yml and poetry.lock files are crucial for the continuity of the new project after the base project, and they are essential for collaboration with team members. While poetry.lock is automatically updated, conda-lock.yml should be manually updated after changes in environment.yml.

## Example Scenario-1

In this example project, FastAPI will be used. Necessary libraries for FastAPI will be installed with poetry, and problematic ones with pip will be installed with conda. The versions of these libraries will be pinned using poetry-lock and conda-lock.

To ensure 100% compatibility between libraries, a base image will be created from the Dockerfile, and a container will be created from this Docker image. Essential libraries will then be installed using poetry and conda. After these installations, all containers created from this Dockerfile will have the same libraries.

- In CMD, go to your Dockerfile Path
- `docker build . -t ubuntu22-python310-base`
- `docker run --rm -it -e SHELL=/bin/bash -v full_path_of_Dockefile_in_your_local:/home/{userNameInDockerFile}/ ubuntu22-python310-base bash `
- Pay attention to the volumes defined with `-v`, both locally and within the container. The paths you specify are important.
- With the `--rm` option, the container will be automatically deleted when you exit the CMD of this container. You can read details about this in the second scenario.
- After entering the container's CMD, navigate to the specified path, `cd /home/{userNameInDockerFile}/`, and start installing the libraries.
- Install a library with `poetry add --lock library_name`
- Then `poetry update`
- Install a library with `conda install library_name=version_number`
- Update environment.yml with `library_name=version_number`
- Update conda-lock.yml with `conda-lock -f environment.yml --lockfile conda-lock.yml`

Since these operations are performed in the Dockerfile's directory, all changes will be automatically saved. Consequently, all containers created from this Docker file will have the installed libraries.

For instance, if you need lib_xx for a new feature in the API, after installing it with poetry or conda, and making necessary changes, if your team members update the dev-branch files and create a new container from this Dockerfile, this container will also have lib_xx.

## Example Scenario-2

You may want to create a local container structure for yourself from this base environment. In this case, you can keep using the image you created from the Dockerfile, and it will be persistent in your system.

- In CMD, go to your Dockerfile Path
- `docker build . -t ubuntu22-python310-base`
- `docker run --name define_spesific_name_for_container -it -e SHELL=/bin/bash -e LANG=C.UTF-8 -e LC_ALL=C.UTF-8 -v full_path_of_Dockefile_in_your_local:/home/{userNameInDockerFile}/ ubuntu22-python310-base bash`
- Replace `define_spesific_name_for_container` with a specific name for the container.
- After creating the container, perform the library installation steps seen in **_scenario-1._**
- After finishing your work with the container, close the CMD window, and check your system's containers with `docker ps -a`. You should see `define_spesific_name_for_container`.
- If you want to reuse the same container, use `docker start define_spesific_name_for_container && docker exec -it define_spesific_name_for_container bash` to access the CMD of the container.

Source links:

- https://stackoverflow.com/questions/70851048/does-it-make-sense-to-use-conda-poetry
- https://stackoverflow.com/questions/77269724/conda-lock-not-working-just-returns-help-info-on-my-macos-sonoma
- https://github.com/pangeo-data/pangeo-docker-images/blob/master/base-image/Dockerfile
- https://github.com/tiangolo/full-stack-fastapi-postgresql/blob/master/src/backend/backend.dockerfile
- https://pythonspeed.com/articles/conda-dependency-management/
- https://blogs.sap.com/2022/05/08/why-you-should-use-poetry-instead-of-pip-or-conda-for-python-projects/
- https://michhar.github.io/2023-07-poetry-with-conda/
