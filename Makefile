.PHONY: all clean

all:
	Rscript code/analysis.R

clean:
	rm -rf output
