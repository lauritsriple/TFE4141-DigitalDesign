(TeX-add-style-hook
 "assignment4"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("fontenc" "T1") ("inputenc" "utf8")))
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art10"
    "fontenc"
    "inputenc"
    "amsmath"
    "amssymb"
    "hyperref"
    "parskip"
    "float"
    "graphicx"
    "listings"
    "cleveref"
    "circuitikz"))
 :latex)

