# Eurostat data

## Install

The following need to be installed to run processing scripts:

* [csvkit](https://csvkit.readthedocs.io/en/latest/)

To install on a Mac:

```sh
brew install csvkit
```

## Extract and Transform Data

To extract and transform data run make:

```sh
make
```

This runs ETL scripts to generate the following:

- [**lists/nuts/nuts-2016.tsv**](/lists/nuts/lau-2018.tsv)
  - list of [Nomenclature of territorial units for statistics classification (NUTS)](https://ec.europa.eu/eurostat/web/nuts/background) sourced from [NUTS download index](https://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/administrative-units-statistical-units/nuts).
- [**lists/nuts/lau-2018.tsv**](/lists/nuts/lau-2018.tsv)
  - list of [Local Administrative Units (LAU)](https://ec.europa.eu/eurostat/en/web/nuts/local-administrative-units).

## Clear Data

To remove generated data files run:

```sh
make clobber
```

## Possible data to include

### Postal Codes

[NUTS-POSTAL](http://ec.europa.eu/eurostat/tercet/flatfilesChangeNutsVersion.do)
