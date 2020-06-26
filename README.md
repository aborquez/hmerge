# hmerge

Merge all the root files in a directory in distinct packs with a certain number of entries, by using `hadd`.

## Usage

To merge all files in order to have files with `N` number of entries.
```
$ ./hmerge.sh --M <number of entries for each output file> <dir>
```
E.G.
```
$ ./hmerge.sh --M 350000 .
```
