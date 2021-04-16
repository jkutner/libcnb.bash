# lincnb.bash

This is a Bash script binding of the Cloud Native Buildpacks API. It is a non-opinionated implementation adding language constructs and convenience methods for working with the API.

## Usage

Source the script directly from the Releases:

```
source https://github.com/jkutner/libcnb.bash/releases/tag/0.0.1
```

Or vendor the `libcnb.bash` script into your buildpack, and source it:

```sh-sesssion
source $CNB_BUILDPACK_DIR/lib/libcnb.bash
```

## License

MIT
