TARGETS=\
	data/contents/table_of_contents_en.tsv\
	lists/nuts/nuts-2016.tsv

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

clobber:
	rm -f $(TARGETS)
