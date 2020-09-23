LISP?=sbcl
TEST_COMMAND='(asdf:test-system :ryeboy)'
sbcl_TEST_OPTS=--noinform --eval $(TEST_COMMAND) --quit


test:
	$(LISP) $($(LISP)_TEST_OPTS)

.PHONY: \
	test
