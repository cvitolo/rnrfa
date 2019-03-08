# THIS FILE CONTAINS PACKAGE HOOKS FOR RNRFA
# ------------------------------------------

# @...: nothing
# spill-over: output information about RNRFA
.onAttach <- function(...) {

  # RNRFA info
  packageStartupMessage("
+----------------------------------------------------------------+
|  If you wish to use NRFA data, please refer to the following   |
|  Terms & Conditions:                                           |
|  http://nrfa.ceh.ac.uk/costs-terms-and-conditions              |
+----------------------------------------------------------------+
")
}
