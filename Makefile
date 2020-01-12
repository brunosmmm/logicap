
SRC_PATH=src/verilog
TEST_PATH=test
LOGICAP_SRCS=aximm_slave.v axisfifo.v capture.v logicap.v trigger.v
SRC_FILES=$(addprefix $(SRC_PATH)/, $(LOGICAP_SRCS))
SIM_FLAGS=-g2012

all: logicaptb

logicaptb: $(TEST_PATH)/logicaptb.v $(SRC_FILES)
	iverilog $(SIM_FLAGS) -o $@ -y$(SRC_PATH) $<

output.txt: logicaptb config.txt input.txt
	./$<

config.txt: config.json cfggen
	./cfggen $< --output $@

simulate: output.txt

clean:
	rm -rf logicaptb

.PHONY: clean
