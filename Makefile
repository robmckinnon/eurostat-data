TARGETS=\
	data/contents/table_of_contents_en.tsv\
	lists/nuts/nuts-2016.tsv\
	lists/nuts/country.tsv\
	lists/nuts/lau-2018.tsv

all: $(TARGETS)

# Eurostat contents

CONTENTS=\
	https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&downfile=table_of_contents_en.txt

data/contents:
	mkdir -p data/contents

data/contents/table_of_contents_en.tsv: data/contents
	curl -qsL "$(CONTENTS)"	> $@

# NUTS16_60M

NUTS16_60M=https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/nuts/download/ref-nuts-2016-60m.shp.zip
NUTS16_60M_CACHE=cache/ref-nuts-2016-01m.shp.zip

cache:
	mkdir -p cache

$(NUTS16_60M_CACHE): cache
	curl -qsL "${NUTS16_60M}" > $@

data/nuts-2016-60m:
	mkdir -p data/nuts-2016-60m

data/nuts-2016-60m/NUTS_AT_2016.csv: $(NUTS16_60M_CACHE) data/nuts-2016-60m
	unzip -p $(NUTS16_60M_CACHE) NUTS_AT_2016.csv > $@

data/nuts-2016-60m/NUTS_RG_BN_60M_2016.csv: $(NUTS16_60M_CACHE) data/nuts-2016-60m
	unzip -p $(NUTS16_60M_CACHE) NUTS_RG_BN_60M_2016.csv > $@

lists/nuts:
	mkdir -p lists/nuts

lists/nuts/nuts-2016.tsv: data/nuts-2016-60m/NUTS_AT_2016.csv lists/nuts
	csvcut -c NUTS_ID,CNTR_CODE,NUTS_NAME data/nuts-2016-60m/NUTS_AT_2016.csv | \
	csvsort -c NUTS_ID | \
	sed 's/NUTS_ID/nuts-2016/' | \
	sed 's/CNTR_CODE/country/' | \
	sed 's/NUTS_NAME/name/' | \
	sed 's/[ ]*$$//' |\
	csvformat -T > $@

lists/nuts/country.tsv: lists/nuts/nuts-2016.tsv
	csvcut -tc country lists/nuts/nuts-2016.tsv | csvsort -t | uniq > $@

# LAU_2018

EU_28_LAU_2018_NUTS_2016=https://ec.europa.eu/eurostat/documents/345175/501971/EU-28-LAU-2018-NUTS-2016.xlsx
EU_28_LAU_2018_NUTS_2016_CACHE=cache/EU-28-LAU-2018-NUTS-2016.xlsx

$(EU_28_LAU_2018_NUTS_2016_CACHE): cache
	curl -qsL "${EU_28_LAU_2018_NUTS_2016}" > $@

data/lau-2018: $(EU_28_LAU_2018_NUTS_2016_CACHE)
	mkdir -p data/lau-2018

countries := $(shell cat lists/nuts/country.tsv | sed 1,1d)
EU-28-LAU-2018-NUTS-2016-FILES := $(addsuffix .tsv,$(addprefix data/lau-2018/EU-28-LAU-2018-NUTS-2016-,${countries}))

${EU-28-LAU-2018-NUTS-2016-FILES}: data/lau-2018/EU-28-LAU-2018-NUTS-2016-%.tsv: data/lau-2018
	in2csv --sheet $* $(EU_28_LAU_2018_NUTS_2016_CACHE) | csvformat -T > $@

data/lau-2018/EU-28-LAU-2018-NUTS-2016-FR.tsv:
	in2csv --sheet FR $(EU_28_LAU_2018_NUTS_2016_CACHE) | csvformat -T > $@.tmp
	cat $@.tmp |\
	sed 's/C.*uvres-et-Valsery/Cœuvres-et-Valsery/' |\
	sed 's/FRF23	51410	.*uilly/FRF23	51410	Œuilly/' |\
	sed 's/FRD11	14087	Bonn.*il/FRD11	14087	Bonnœil/' |\
	sed 's/Cricqueb.*uf/Cricquebœuf/' |\
	sed 's/Morteaux-Coulib.*uf/Morteaux-Coulibœuf/' |\
	sed 's/Montemb.*uf/Montembœuf/' |\
	sed 's/V.*uil-et-Giget/Vœuil-et-Giget/' \
	> $@
	rm $@.tmp

lists/nuts/lau-2018.tsv: lists/nuts/country.tsv data/lau-2018/EU-28-LAU-2018-NUTS-2016-FR.tsv
	csvstack ${EU-28-LAU-2018-NUTS-2016-FILES} |\
	csvcut -txc "2,1,3,4" |\
	csvsort -c "2,1" |\
	grep -v 'Population data' |\
	sed 's/LAU CODE/lau-2018/' |\
	sed 's/NUTS 3 CODE/nuts-2016/' |\
	sed 's/LAU NAME NATIONAL/name/' |\
	sed 's/LAU NAME LATIN/name-latin/' |\
	sed 's/[ ][ ]+/ /' |\
	sed 's/[ ]*$$//' |\
	csvformat -T \
	> $@

clobber:
	rm -f $(TARGETS)
