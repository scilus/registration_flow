# Registration-flow pipeline
============================


Requirements
------------

- [Nextflow](https://www.nextflow.io)
- [ANTs](http://stnava.github.io/ANTs/)
  
If you also want to transform tractograms (.trk):
- [scilpy](https://github.com/scilus/scilpy)


Docker
------
If you are on MacOS or Windows, we recommend using the Docker container to run registration-flow

Prebuilt Docker images are available here:

[http://scil.usherbrooke.ca/en/containers_list/](http://scil.usherbrooke.ca/en/containers_list/)

Or use the available Docker image online:
[scilus/scilus:1.1.0_registrationflow-1.0.0](https://hub.docker.com/layers/scilus/scilus/1.1.0_registrationflow-1.0.0/images/sha256-1726d651667a964f7b0808b8383fac6a92c1c126c45a940da1d7ea5a1693bdb0)

FOR DEVELOPERS: The containers repository is available here:
[containers-TractoFlow](https://github.com/scilus/containers-tractoflow)


Usage
-----

See *USAGE* or run `nextflow run main.nf --help`
