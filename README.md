## Containers Repo

This repo contains Docker images which are used in other repos, such as the 
[firmware repo](https://github.com/concordia-fsae/firmware), for various purposes.


## Updating these containers

1. Make the desired changes, commit, and push
2. Build the image, applying the relevant tags  
   eg.`docker build -t <container name>:latest -t <container name>:v0.0.0 .`
   note: the container name here should include the repository path, e.g. `ghcr.io/concordia-fsae/containers/ubuntu-jammy-2022.04.21`
3. Authenticate to the GitHub Container Registry using a Personal Access Token (classic)
   (see [here](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry) for more details) using  
   `docker login ghcr.io -u <username>`  
   providing your PAT when prompted for a password
4. Push the image  
   eg. `docker push -a ghcr.io/concordia-fsae/containers/<container name>`

