# Python & Docker Base Environment For New Projects

Create a base environment with Python 3.11, conda, mamba, pip, conda-lock, and poetry==1.3.1. This structure allows manipulation of the Docker environment based on the project's needs.

- Dockerfile
- environment.yml
- conda-lock.yml # This file will be empty when base image files are first pulled. It should be created by the admin after creating the environment.
- pyproject.toml

In this structure, while managing libraries with poetry, problematic ones with pip can be added via conda. The versions of used libraries can be pinned with conda-lock.

If you only want to work with pipenv, after downloading the system, you can add the lines of the requirements.txt file to the poetry.toml file. We plan to automate the process of importing the requirements.txt file later with a script.

Add a library to poetry.lock with `poetry add --lock library_name`. This automatically updates the poetry.toml file.

If a library is installed with conda, its version should be added manually by user to the environment.yml file.

`libray_name=version_number`

Then, the conda-lock.yml file is updated with:

`conda-lock -f environment.yml --lockfile conda-lock.yml`

Update your lock file you should delete the old one and create a new one with the same name.

Both conda-lock.yml and poetry.lock files are crucial for the continuity of the new project after the base project, and they are essential for collaboration with team members. While poetry.lock is automatically updated, conda-lock.yml should be manually updated after changes in environment.yml.

### Dockerfile & User and Group Settings

When working with environments in Docker, especially for Linux users, it's crucial to define parameters such as the Conda environment name, Python version, and most importantly, the user's username and user ID (UID), as well as the user's group and group ID (GID). These parameters need to be correctly defined in the Dockerfile to ensure smooth operation, whether on personal computers or servers.

You can find your username, UID, group, and GID by running the id command. Here's an example output:

`uid=1001(akif) gid=1003(akif) groups=1003(akif),27(sudo),999(docker),1002(developer)`

In this example, the username "akif" has a UID of 1001 and belongs to the group "akif" with a GID of 1003. Additionally, it's a member of other groups as well.

To create an image with these parameters, you can use the following commands:

    Build the image: `docker build . -t docker-personal-usage`
    Create a container: `docker run -it --rm -v $HOME:$HOME:rw -p 8888:8888 docker-personal-usage  --name jupyter-container bash`

Setting up these parameters is important due to file permissions in Linux. Failure to define the username, group, and other settings in the Docker image and container can lead to issues when accessing files directly from the PC or laptop while outside the Docker environment.
Personal PC or Laptop Environment

For an environment used solely by you, both the username and group can be set to your username, such as "akif:akif" or "1001:1003". You can make the necessary changes in the Dockerfile to create this environment.

You can use the ls -l -a command to see the username, UID, group, and GID of files and directories in your home directory. Use these username and group information to define the environment variables in the Dockerfile.
Server Environment

Let's consider a scenario where a workstation is shared among software developers and data scientists. Some parameters related to user permissions are necessary:

    - Users can view each other's files but cannot modify them.
    - Only spesific user has admin or sudo privileges.
    - Every user can access Docker.
    - Admins open specific port ranges by default to allow users to access the machine via SSH, Jupyter, or web applications.

The username:group scenario described above emerged as a requirement during the setup of such a scenario. Therefore, it's essential to define the environment variables in the Dockerfile for this scenario.

!!! IMPORTANT !!!

All users who will use this structure on the workstation must define the environment variables in the Dockerfile according to their parameters.

    -Open your CMD and use `id` command to find the user ID and group ID.
    -If there's a common group defined by the admin, this group ID should be entered into the system.
    (For our use case docker gruop ID is 999 defined by the admin)
    - Then, the Docker structure is created according to this setup.

### Environment.yml Files

For example purposes, there are two environment.yml files provided. One is for the base image, and the other is derived from the Pangeo Notebook image settings, named envrionment_geo.yml.

If you want to start a new API project or data science project from scratch, you can directly use the basic environment.yml file.

If you'll be working with geospatial data using Jupyter notebook, you can use the envrionment_geo.yml file. To do this, delete the default environment.yml file and rename the envrionment_geo.yml file to environment.yml. If you look at the ENV section in the Dockerfile, the system expects you to provide the environment.yml file.

## Example Scenario-1

In this example project, FastAPI will be used. Necessary libraries for FastAPI will be installed with poetry, and problematic ones with pip will be installed with conda. The versions of these libraries will be pinned using poetry-lock and conda-lock.

To ensure 100% compatibility between libraries, a base image will be created from the Dockerfile, and a container will be created from this Docker image. Essential libraries will then be installed using poetry and conda. After these installations, all containers created from this Dockerfile will have the same libraries.

- In CMD, go to your Dockerfile Path
- `docker build . -t ubuntu22-python311-base`
- `docker run --rm -it -e SHELL=/bin/bash -v \
full_path_of_Dockefile_in_your_local:/home/{userNameInDockerFile}/
ubuntu22-python311-base bash `
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
- `docker build . -t ubuntu22-python311-base`
- `docker run --name define_spesific_name_for_container -it -e SHELL=/bin/bash -e LANG=C.UTF-8 -e LC_ALL=C.UTF-8 -v full_path_of_Dockefile_in_your_local:/home/{userNameInDockerFile}/ ubuntu22-python311-base bash`
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
