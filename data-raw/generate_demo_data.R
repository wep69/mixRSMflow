# Reproducible data-generation script for package examples.
# No textbook or proprietary data are copied by this script.

spec <- mixRSMflow::mix_spec(c("A", "B", "C"))
mixture_demo <- mixRSMflow::mix_demo_data("mixture", n_rep = 3, seed = 20260813)
process_demo <- mixRSMflow::mix_demo_data("mixture_process", seed = 20260814)
multi_demo <- mixRSMflow::mix_demo_data("multiresponse", n_rep = 3, seed = 20260815)

# If package data objects are desired in a future release, use usethis::use_data()
# locally after checking documentation and licensing.
