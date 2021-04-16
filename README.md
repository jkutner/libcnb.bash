# libcnb.bash

This is a Bash binding of the Cloud Native Buildpacks API. It is a non-opinionated implementation adding language constructs and convenience methods for working with the API.

## Usage

Source the script directly from the Releases:

```
source "https://github.com/jkutner/libcnb.bash/releases/download/0.0.1/libcnb.bash"
```

Or vendor the `libcnb.bash` script into your buildpack, and source it:

```sh-sesssion
source $CNB_BUILDPACK_DIR/lib/libcnb.bash
```

## License

MIT
