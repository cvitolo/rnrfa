# THIS FILE CONTAINS PACKAGE HOOKS FOR RNRFA
# ------------------------------------------

# @...: nothing
# spill-over: output information about RNRFA
.on_attach <- function(...) {

  # RNRFA info
  packageStartupMessage("+--------------------------------------------------+
| Acknowledgement:                                 |
| Data from the UK National River Flow Archive     |
| Terms & Conditions:                              |
| http://nrfa.ceh.ac.uk/costs-terms-and-conditions |
+--------------------------------------------------+")
}
