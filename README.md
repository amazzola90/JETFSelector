# JETFSelector
A simple interface to select and query ETF information from the website JustEtf.com

## Requirements
In order to use JETFSelector you need to install the [GUI Layout Toolbox](https://it.mathworks.com/matlabcentral/fileexchange/27758-gui-layout-toolbox), available in the Matlab file exchange (also available from the Add On library directly from within Matlab).

## How to use 
After installing GUI Layout Toolbox, you just need to navigate within the main folder of JETFSelector and launch the script JETFSelector.m
The tool will connect to the JustEtf website to download the list of all available ETF, ETC and ETN. Few filter options are available to easily identify the assets of interest. 
The user can therefore select one or more assets in in the dual list object. Clicking on Apply, the code will exit the interface and return a structure of structures, whose fields are the selected ETF isins. Each ETF structure instead contains the main asset downloaded from JustEtf.com.



