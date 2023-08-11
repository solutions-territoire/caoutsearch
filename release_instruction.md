# Release instructions

Use [gem_release](https://github.com/svenfuchs/gem-release) to publish new versions.

First, create a new tag with one of the following command:
```shell
gem bump --push # Create a new patch
gem bump --push --version minor
gem bump --push --version major
```

**Don't forget to add the new version to `retype.yml`!**  
(until we figure out how to automate this step).

Then, publish the version on rubygem:

```shell
gem release
```

Caoutsearch is still under developement, so we don't take time to communicate changes on every release.  
When it'll be ready for public diffusion, add a release on github.
