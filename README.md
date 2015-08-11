# Filesystem IO tests

A simple bash harness to benchmark network-bound filesystem operations.

## Getting started

1. Ensure you have a folder available on the filesystem you're benchmarking
   owned by unprivileged user you're going to run this suite under.
1. Clone this repository as the unprivileged user.
1. run `./bin/setup`
1. run `./bin/benchmark <the folder on the filesystem of concern>`

## Tests we run

Read './bin/benchmark.sh' for more details. Summary:

* We run the non-CPU bound tests from `bonnie++`,
* We copy and then read increasingly large files in parallel, up to 2x max RAM
  to ensure we're not seeing buffer cache interference (eventually, at the
  large file sizes).

Output is dumped into a format suitable for import into a spreadsheet in the
directory you run `./bin/benchmark.sh` from. You should be able to run this
suite in a cron job, but make sure you don't let them overlap, using something
like `lockrun,` perhaps.

## Contributors

* Dan Collis-Puro - [djcp](https://github.com/djcp)

## License

This project is licensed under the same terms as [the ruby aws-sdk
itself](https://github.com/aws/aws-sdk-ruby/tree/master#license).

## Copyright

2015 President and Fellows of Harvard College
