PROTOBUF_DEFINITION=https://raw.githubusercontent.com/aphyr/riemann-java-client/master/src/main/proto/riemann/proto.proto
PROTOC=$(shell which protoc 2> /dev/null)
PROTOC_GEN_LISP=git://github.com/brown/protobuf.git
PLUGIN=$(shell which protoc-gen-lisp 2> /dev/null)
ifeq ($(PLUGIN),)
PLUGIN_PATH=./bin/protoc-gen-lisp
else
PLUGIN_PATH=$(PLUGIN)
endif

.PHONY: \
	protobuf-compiler

$(PLUGIN_PATH):
	@mkdir -p bin
	@git clone $(PROTOC_GEN_LISP) /tmp/protobufs/ && \
		cd /tmp/protobufs/protoc/lisp && \
		make
	@cp /tmp/protobufs/protoc/lisp/protoc-gen-lisp ./bin/ && \
		yes | rm -r /tmp/protobufs/

protobuf-compiler: $(PLUGIN_PATH)

proto.proto:
	wget $(PROTOBUF_DEFINITION)

proto.lisp: proto.proto
	$(PROTOC) --plugin=./$(PLUGIN_PATH) --proto_path=. --lisp_out=. $<
