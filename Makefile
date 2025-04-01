name = "solve"


default: bnr;


build:
	@fpc ${name}$$N.dpr -obin_${name}$$N

run:
	@./bin_${name}$$N
	
bnr:
	@echo "\n\n---===---\nbuilding... \n---===---\n\n"
	@make build
	@echo "\n\n---===---\nbuild done \ntrying to run:\n---===---\n\n"
	@make run

