TARGETS=\
	data/table_of_contents_en.tsv

CONTENTS=\
	https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&downfile=table_of_contents_en.txt

all:	$(TARGETS)

data/table_of_contents_en.tsv:
	curl -qsL "$(CONTENTS)"	> $@

clobber:
	rm -f $(TARGETS)
