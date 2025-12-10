# ldmppr

<details>

* Version: 1.0.4
* GitHub: https://github.com/lanedrew/ldmppr
* Source code: https://github.com/cran/ldmppr
* Date/Publication: 2025-02-24 21:00:02 UTC
* Number of recursive dependencies: 128

Run `revdepcheck::revdep_details(, "ldmppr")` for more info

</details>

## In both

*   checking whether package ‘ldmppr’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/Users/juliasilge/Work/posit/bundle/revdep/checks.noindex/ldmppr/new/ldmppr.Rcheck/00install.out’ for details.
    ```

## Installation

### Devel

```
* installing *source* package ‘ldmppr’ ...
** this is package ‘ldmppr’ version ‘1.0.4’
** package ‘ldmppr’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C++ compiler: ‘Apple clang version 17.0.0 (clang-1700.4.4.1)’
using C++17
using SDK: ‘MacOSX26.1.sdk’
clang++ -arch arm64 -std=gnu++17 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/juliasilge/Work/posit/bundle/revdep/library.noindex/ldmppr/Rcpp/include' -I'/Users/juliasilge/Work/posit/bundle/revdep/library.noindex/ldmppr/RcppArmadillo/include' -I/opt/R/arm64/include    -fPIC  -falign-functions=64 -Wall -g -O2   -c RcppExports.cpp -o RcppExports.o
clang++ -arch arm64 -std=gnu++17 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/juliasilge/Work/posit/bundle/revdep/library.noindex/ldmppr/Rcpp/include' -I'/Users/juliasilge/Work/posit/bundle/revdep/library.noindex/ldmppr/RcppArmadillo/include' -I/opt/R/arm64/include    -fPIC  -falign-functions=64 -Wall -g -O2   -c self_correcting_model.cpp -o self_correcting_model.o
clang++ -arch arm64 -std=gnu++17 -dynamiclib -Wl,-headerpad_max_install_names -undefined dynamic_lookup -L/Library/Frameworks/R.framework/Resources/lib -L/opt/R/arm64/lib -o ldmppr.so RcppExports.o self_correcting_model.o -L/Library/Frameworks/R.framework/Resources/lib -lRlapack -L/Library/Frameworks/R.framework/Resources/lib -lRblas -L/opt/gfortran/lib/gcc/aarch64-apple-darwin20.0/14.2.0 -L/opt/gfortran/lib -lemutls_w -lheapt_w -lgfortran -lquadmath -F/Library/Frameworks/R.framework/.. -framework R
ld: warning: search path '/opt/gfortran/lib/gcc/aarch64-apple-darwin20.0/14.2.0' not found
ld: warning: search path '/opt/gfortran/lib' not found
ld: library 'emutls_w' not found
clang++: error: linker command failed with exit code 1 (use -v to see invocation)
make: *** [ldmppr.so] Error 1
ERROR: compilation failed for package ‘ldmppr’
* removing ‘/Users/juliasilge/Work/posit/bundle/revdep/checks.noindex/ldmppr/new/ldmppr.Rcheck/ldmppr’


```
### CRAN

```
* installing *source* package ‘ldmppr’ ...
** this is package ‘ldmppr’ version ‘1.0.4’
** package ‘ldmppr’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C++ compiler: ‘Apple clang version 17.0.0 (clang-1700.4.4.1)’
using C++17
using SDK: ‘MacOSX26.1.sdk’
clang++ -arch arm64 -std=gnu++17 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/juliasilge/Work/posit/bundle/revdep/library.noindex/ldmppr/Rcpp/include' -I'/Users/juliasilge/Work/posit/bundle/revdep/library.noindex/ldmppr/RcppArmadillo/include' -I/opt/R/arm64/include    -fPIC  -falign-functions=64 -Wall -g -O2   -c RcppExports.cpp -o RcppExports.o
clang++ -arch arm64 -std=gnu++17 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG  -I'/Users/juliasilge/Work/posit/bundle/revdep/library.noindex/ldmppr/Rcpp/include' -I'/Users/juliasilge/Work/posit/bundle/revdep/library.noindex/ldmppr/RcppArmadillo/include' -I/opt/R/arm64/include    -fPIC  -falign-functions=64 -Wall -g -O2   -c self_correcting_model.cpp -o self_correcting_model.o
clang++ -arch arm64 -std=gnu++17 -dynamiclib -Wl,-headerpad_max_install_names -undefined dynamic_lookup -L/Library/Frameworks/R.framework/Resources/lib -L/opt/R/arm64/lib -o ldmppr.so RcppExports.o self_correcting_model.o -L/Library/Frameworks/R.framework/Resources/lib -lRlapack -L/Library/Frameworks/R.framework/Resources/lib -lRblas -L/opt/gfortran/lib/gcc/aarch64-apple-darwin20.0/14.2.0 -L/opt/gfortran/lib -lemutls_w -lheapt_w -lgfortran -lquadmath -F/Library/Frameworks/R.framework/.. -framework R
ld: warning: search path '/opt/gfortran/lib/gcc/aarch64-apple-darwin20.0/14.2.0' not found
ld: warning: search path '/opt/gfortran/lib' not found
ld: library 'emutls_w' not found
clang++: error: linker command failed with exit code 1 (use -v to see invocation)
make: *** [ldmppr.so] Error 1
ERROR: compilation failed for package ‘ldmppr’
* removing ‘/Users/juliasilge/Work/posit/bundle/revdep/checks.noindex/ldmppr/old/ldmppr.Rcheck/ldmppr’


```
