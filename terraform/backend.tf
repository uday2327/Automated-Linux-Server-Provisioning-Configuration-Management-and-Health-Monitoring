terraform {
  backend "s3" {
    # Supply bucket, key, region and use_lockfile via -backend-config.
    # The bucket must be created and secured before normal terraform init.
  }
}
