# bundle: Serialize Model Objects with a Consistent Interface

Typically, models in 'R' exist in memory and can be saved via regular
'R' serialization. However, some models store information in locations
that cannot be saved using 'R' serialization alone. The goal of 'bundle'
is to provide a common interface to capture this information, situate it
within a portable object, and restore it for use in new settings.

## See also

Useful links:

- <https://github.com/rstudio/bundle>

- <https://rstudio.github.io/bundle/>

- Report bugs at <https://github.com/rstudio/bundle/issues>

## Author

**Maintainer**: Julia Silge <julia.silge@posit.co>
([ORCID](https://orcid.org/0000-0002-3671-836X))

Authors:

- Simon Couch <simonpatrickcouch@gmail.com>

- Qiushi Yan <qiushi.yann@gmail.com>

- Max Kuhn <max@posit.co>

Other contributors:

- Posit Software, PBC ([ROR](https://ror.org/03wc8by49)) \[copyright
  holder, funder\]
