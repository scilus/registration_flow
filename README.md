# Registration-flow pipeline
============================


Requirements
------------

- [Nextflow](https://www.nextflow.io)
- [ANTs](http://stnava.github.io/ANTs/)
  
If you also want to transform tractograms (.trk):
- [scilpy](https://github.com/scilus/scilpy)


Singularity
-----------
If you are on Linux, we recommend using the Singularity container to run registration-flow.

Download the available singularity image here:
[scilus-1.1.0_registrationflow-1.0.0.img](http://scil.usherbrooke.ca/en/containers_list/scilus-1.1.0_registrationflow-1.0.0.img)

Then add the following to your `nextflow run` command:

`-with-singularity /pathto/scilus-1.1.0_registrationflow-1.0.0.img`


FOR DEVELOPERS: The containers repository is available here:
[containers-TractoFlow](https://github.com/scilus/containers-tractoflow)


Docker
------
If you are on MacOS or Windows, we recommend using the Docker container to run registration-flow

Simply add the following to your `nextflow run` command:
`-with-docker scilus/scilus:1.1.0_registrationflow-1.0.0`


FOR DEVELOPERS: The containers repository is available here:
[containers-TractoFlow](https://github.com/scilus/containers-tractoflow)


Usage
-----

See *USAGE* or run `nextflow run main.nf --help`
