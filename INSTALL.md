## Debian / Ubuntu

To build the .deb archive, run:

```
debuild -us -uc
```

Once the .deb has been built, *dpkg -i* the archive.


## All Others

```
perl Makefile.PL
make
make install
```
