# About - OpenAIRE research graph coverage with the OpenAPC initiative dataset

This project calcualte the dataset coverage from OpenAPC initiative ( https://github.com/OpenAPC/openapc-de
) with OpenAIRE research graph ( https://www.openaire.eu )

*This is an experimental developer preview release.* 


# Requirements
1. **OpenAPC_de dataset** from github repository
 https://github.com/OpenAPC/openapc-de. 

Checkout parallel to this directory: 

	$ git clone https://github.com/OpenAPC/openapc-de

2. **curl**, for requesting results from OpenAIRE API

3. **xmllint** and **xmlstarlet**, to handle xml results
  
   http://xmlsoft.org/xmllint.html

   http://xmlstar.sourceforge.net/



# Usage

	$ chmod +x evalDOIonOA.sh
	$ ./evalDOIonOA.sh


This shell script calculates the coverage of OpenAPC dataset DOIs with the OpenAIRE.
It's check's the OpenAPC DOI on the OpenAIRE API and collect some
information.
If a DOI is checked at OpenAIRE (on the same same date) it skips the request.


# Releases
For release notes see https://github.com/ACz-UniBi/OpenAIRE-OpenAPC_coverage/blob/master/RELEASE-NOTES.md

# License
Free software - GPL v3
see https://github.com/ACz-UniBi/OpenAIRE-OpenAPC_coverage/blob/master/LICENSE 


# Maintainers
see https://github.com/ACz-UniBi/OpenAIRE-OpenAPC_coverage/blob/master/MAINTAINERS
