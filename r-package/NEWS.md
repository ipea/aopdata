# aopdata v1.1.2

**Minor changes**

- Messages and errors now use {cli}
- Avoid printing internet connection messages twice

**Bug fixes**

- Updated vignettes to avoid error in case of eventual internet connection issue.
- Now using the latest version of {rmarkdown}.


# aopdata v1.1.1

**Bug fixes**

- Download functions should now fail gracefully with an informative message when there are internet connection problems. Making sure to propagate the internet connection issue across function levels.


# aopdata v1.1.0

**Minor changes**

- Simplified internal functions
- Removed dependency on the {httr} package
- Now using `curl::multi_download()` to download files in parallel



# aopdata v1.0.3

**Bug fixes**

- Simplified internal functions
- Download functions should now fail gracefully with an informative message when there are internet connection problems. Using a more robust solution now that also accounts for timeout.


# aopdata v1.0.2

**Bug fixes**

- Fixed bug that printed message 'connection fail' in the 1st attempt, when it should only print in the 2nd attempt
- updated CITATION file with bibentry()


# aopdata v1.0.1

**Minor changes**

- Remove code redundancy from main read_ and download function
- Do not throw connection error message in first check
- Improve error message when `mode = car`. Closes #52
- Added citation file

**Bug fixes**

- Fixed bug that did not allow one to download access estimates by car in off-peak period. Closes #53



# aopdata v1.0.0

**Major changes**

- New function `aopdata_dictionary()` to open the aopdata data dictionary on a web browser.
- All data sets are now simultaneously stored on github and on Ipea's server. The package now downloads the data from github. In case the github link is off line for some reason, then the package tries to download the data from Ipea's server. For users, the effect of this change is that the package is much more stable and less vulnerable to instabilities in Ipea's data server connection.
- New data sets:
  - Year coverage
    - Access and Land use data sets now cover years **2017, 2018 and 2019**

  - New cities
    - Data for Goiania now covers the entire **metro area of Goiania** in 2019.

  - New modes
    - Access data now bring accessibility estimates by **car** in 2019

  - New activities
    - Land use and access data now bring data for **centers for social assistance (CRAS)**
    - Population data sets with minor spatial corrections to smooth spatial distributions


**Minor changes**

- `read_` functions now have no default value for the `city` parameter. [Closes #38](https://github.com/ipea/aopdata/issues/38).
- Fixed `ERROR` message when there is no data for a particular transport mode for an specific city & year.




# aopdata v0.2.3

**Minor changes**

- Download functions should now fail gracefully with an informative message when there are internet connection problems.
- Remove `crul` from package dependencies.
- skip examples on CRAN. Examples now only run on interactive R sessions.
- update links from http to https



# aopdata v0.2.2

**Minor changes**

- Adds `crul` as a package dependency. Now aoptadata fails gracefully when there is internet connection problems. Closes #32.
- `showProgress` now sets to `FALSE` in all tests, examples and vignettes. Closes #32.
- skip tests on CRAN. Tests are run only locally




# aopdata v0.2.1

**Minor changes**

- Allow for user to download data few selected cities. Closes #29
- Fix  progress bar even when showProgress = F. Closes #30
- Fix  encoding issues using `base::iconv(city, to="ASCII//TRANSLIT")`. Closes #31




# aopdata v0.2.0

**Major changes**

- New function read_population. Closes #21
- New parameter `peak` added to `read_access()` function. Closes #17
- New internal support function `is_online()` to alert for possible internet connection problem. Closes #26
- Cache downloaded data in tempdir. Closes #28

**Minor changes**

- Downloads two or more cities at the same time. Closes #3.



# aopdata v0.1.0

- First version on CRAN
