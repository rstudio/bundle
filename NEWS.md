# bundle 0.1.2

* Added bundle method for objects from `dbarts::bart()` and, by extension, `parsnip::bart(engine = "dbarts")` (#64).

* Bundling xgboost objects now takes extra steps to preserve `nfeatures` and `feature_names` (#67).

# bundle 0.1.1

* Fixed bundling of recipes steps situated inside of workflows.

* Updated required version of xgboost (#62, thanks to @MichaelChirico).

# bundle 0.1.0

* Initial CRAN release of package
