
SRC_PATH=src/verilog
TEST_PATH=test/src
LOGICAP_SRCS=aximm_slave.v axisfifo.v capture.v logicap.v trigger.v
SRC_FILES=$(addprefix $(SRC_PATH)/, $(LOGICAP_SRCS))
SIM_FLAGS=-g2012
TEST_CONFIG_PATH=test/configs

all: logicaptb

logicaptb: $(TEST_PATH)/logicaptb.v $(SRC_FILES)
	iverilog $(SIM_FLAGS) -o $@ -y$(SRC_PATH) $<

output%.txt: logicaptb config%.txt input%.txt
	./$< +configfile=config$(*F).txt +inputfile=input$(*F).txt +outputfile=output$(*F).txt

input%.json: input%.vg
	vgc $< --output $@

config%.txt: $(TEST_CONFIG_PATH)/config%.json cfggen
	./cfggen $< --output $@

input%.txt: $(TEST_CONFIG_PATH)/input%.json
	inputgen $< --output $@

simulate1: output1.txt logicaptb

clean:
	rm -rf logicaptb output*.txt config*.txt input*.txt

.PHONY: clean simulate
