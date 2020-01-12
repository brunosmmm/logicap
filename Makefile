
SRC_PATH=src/verilog
TEST_PATH=test
LOGICAP_SRCS=aximm_slave.v axisfifo.v capture.v logicap.v trigger.v
SRC_FILES=$(addprefix $(SRC_PATH)/, $(LOGICAP_SRCS))
SIM_FLAGS=-g2012

all: logicaptb

logicaptb: $(TEST_PATH)/logicaptb.v $(SRC_FILES)
	iverilog $(SIM_FLAGS) -o $@ -y$(SRC_PATH) $<

sim_out.txt: logicaptb
	./logicaptb

simulate: sim_out.txt

clean:
	rm -rf logicaptb

.PHONY: clean
