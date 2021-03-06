<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id$

     This file is part of Invenio.
     Copyright (C) 2007, 2008, 2010, 2011, 2016 CERN.

     Invenio is free software; you can redistribute it and/or
     modify it under the terms of the GNU General Public License as
     published by the Free Software Foundation; either version 2 of the
     License, or (at your option) any later version.

     Invenio is distributed in the hope that it will be useful, but
     WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
     General Public License for more details.

     You should have received a copy of the GNU General Public License
     along with Invenio; if not, write to the Free Software Foundation, Inc.,
     59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
-->
<!--
<name>DataCite</name>
<description>DataCite XML</description>
-->
<!--
This stylesheet transforms a MARCXML input into DataCite output.
-->
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:marc="http://www.loc.gov/MARC21/slim"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns:fn="http://cdsweb.cern.ch/bibformat/fn"
xmlns:invenio="http://inveniosoftware.org/elements/1.0"
xmlns:contributors="marc.contributors"
exclude-result-prefixes="marc fn dc invenio contributors">
    <xsl:output method="xml"  indent="yes" encoding="UTF-8" omit-xml-declaration="yes"/>
    <xsl:variable name="LOWERCASE" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="UPPERCASE" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <contributors:map>
        <entry key="prc">ContactPerson</entry>
        <entry key="col">DataCollector</entry>
        <entry key="dtm">DataManager</entry>
        <entry key="edt">Editor</entry>
        <entry key="pro">Producer</entry>
        <entry key="res">Researcher</entry>
        <entry key="cph">RightsHolder</entry>
        <entry key="spn">Sponsor</entry>
        <entry key="ths">Supervisor</entry>
    </contributors:map>
    <xsl:template match="/">
        <xsl:if test="collection">
        </xsl:if>
        <xsl:if test="record">
            <oai_datacite xsi:schemaLocation="http://schema.datacite.org/oai/oai-1.0/ http://schema.datacite.org/oai/oai-1.0/oai.xsd">
                <isReferenceQuality>true</isReferenceQuality>
                <schemaVersion>2.2</schemaVersion>
                <datacentreSymbol>CERN.ZENODO</datacentreSymbol>
                <payload>
                    <resource xmlns="http://datacite.org/schema/kernel-2.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://datacite.org/schema/kernel-2.2 http://schema.datacite.org/meta/kernel-2.2/metadata.xsd">
                    <xsl:apply-templates />
                    </resource>
                </payload>
            </oai_datacite>
        </xsl:if>
    </xsl:template>
    <xsl:template match="record" xmlns="http://datacite.org/schema/kernel-2.2">
        <!-- 1. Identifier -->
        <xsl:choose>
            <xsl:when test="datafield[@tag=024 and @ind1=7]">
                <xsl:for-each select="datafield[@tag=024 and @ind1=7]">
                    <xsl:if test="subfield[@code='2'] = 'DOI'">
                        <identifier>
                            <xsl:attribute name="identifierType">
                                <xsl:value-of select="subfield[@code='2']"/>
                         </xsl:attribute>
                            <xsl:value-of select="subfield[@code='a']"/>
                        </identifier>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <identifier identifierType="URL"><xsl:value-of select="fn:eval_bibformat(controlfield[@tag=001],'&lt;BFE_RECORD_URL absolute=&quot;yes&quot; with_ln=&quot;no&quot;>')"/></identifier>
            </xsl:otherwise>
        </xsl:choose>
        <!-- 2. Creators -->
        <creators xmlns="http://datacite.org/schema/kernel-2.2">
            <xsl:for-each select="datafield[@tag=100]">
                <creator>
                <creatorName>
                    <xsl:value-of select="subfield[@code='a']"/>
                </creatorName>
                <xsl:for-each select="subfield[@code='0']">
                    <xsl:if test="substring(., 2, 5) = 'orcid'">
                        <nameIdentifier schemeURI="http://orcid.org" nameIdentifierScheme="ORCID">
                            <!-- parse only id from (orcid)xxxx-xxxx-xxxx -->
                            <xsl:value-of select="substring(., 8)"/>
                        </nameIdentifier>
                    </xsl:if>
                </xsl:for-each>
                </creator>
            </xsl:for-each>
            <xsl:for-each select="datafield[@tag=700]">
                <creator>
                <creatorName>
                    <xsl:value-of select="subfield[@code='a']"/>
                </creatorName>
                <xsl:for-each select="subfield[@code='0']">
                    <xsl:if test="substring(., 2, 5) = 'orcid'">
                        <nameIdentifier schemeURI="http://orcid.org" nameIdentifierScheme="ORCID">
                            <!-- parse only id from (orcid)xxxx-xxxx-xxxx -->
                            <xsl:value-of select="substring(., 8)"/>
                        </nameIdentifier>
                    </xsl:if>
                </xsl:for-each>
                </creator>
            </xsl:for-each>
        </creators>
        <!-- 3. Titles -->
        <titles>
            <xsl:for-each select="datafield[@tag=245]">
                <title>
                    <xsl:value-of select="subfield[@code='a']"/>
                        <xsl:if test="subfield[@code='b']">
                            <xsl:text>: </xsl:text><xsl:value-of select="subfield[@code='b']"/>
                        </xsl:if>
                </title>
            </xsl:for-each>
        </titles>
        <!-- 4. Publisher -->
        <publisher>
            <xsl:choose>
                <xsl:when test="datafield[@tag=260]/subfield[@code='b']">
                    <xsl:value-of select="datafield[@tag=260]/subfield[@code='b']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="fn:eval_bibformat(controlfield[@tag=001],'&lt;BFE_SERVER_INFO var=&quot;CFG_SITE_NAME&quot; >')"/>
                </xsl:otherwise>
            </xsl:choose>
        </publisher>
        <!-- 5. PublicationYear -->
        <publicationYear>
                <xsl:value-of select="fn:eval_bibformat(controlfield[@tag=001],'&lt;BFE_YEAR >')"/>
        </publicationYear>
        <!-- 6. Subject -->
        <xsl:if test="datafield[@tag=653 and @ind1='1'] or datafield[@tag=650 and @ind1='1' and @ind2=' ']">
            <subjects>
                <xsl:for-each select="datafield[@tag=653 and @ind1='1']">
                    <subject><xsl:value-of select="subfield[@code='a']"/></subject>
                </xsl:for-each>
                <xsl:for-each select="datafield[@tag=650 and @ind1='1' and @ind2=' ']">
                    <subject>
                        <xsl:attribute name="subjectScheme">
                            <xsl:value-of select="substring-after(substring-before(subfield[@code='0'], ')'), '(')"/>
                        </xsl:attribute>
                        <xsl:value-of select="substring-after(subfield[@code='0'], ')')"/>
                    </subject>
                </xsl:for-each>
            </subjects>
        </xsl:if>
        <!-- 7. Contributor -->
        <xsl:if test="datafield[@tag=536]">
            <contributors>
                <xsl:for-each select="datafield[@tag=536]">
                    <contributor contributorType="Funder">
                        <contributorName>European Commission</contributorName>
                        <nameIdentifier nameIdentifierScheme="info">info:eu-repo/grantAgreement/EC/FP7/<xsl:value-of select="subfield[@code='c']"/></nameIdentifier>
                    </contributor>
                </xsl:for-each>
            </contributors>
        </xsl:if>
        <!-- 8. Date -->
        <dates>
            <xsl:choose>
                <xsl:when test="datafield[@tag=942]">
                    <xsl:for-each select="datafield[@tag=260]">
                        <date dateType="Accepted"><xsl:value-of select="subfield[@code='c']"/></date>
                    </xsl:for-each>
                    <xsl:for-each select="datafield[@tag=942]">
                        <date dateType="Available"><xsl:value-of select="subfield[@code='a']"/></date>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="datafield[@tag=260]">
                        <date dateType="Issued"><xsl:value-of select="subfield[@code='c']"/></date>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </dates>
        <!-- 9. Language -->
        <xsl:for-each select="datafield[@tag=041]">
            <language>
                <xsl:value-of select="subfield[@code='a']"/>
            </language>
        </xsl:for-each>
        <!-- 10 ResourceType -->
        <xsl:for-each select="datafield[@tag=980]">
            <xsl:choose>
                <xsl:when test="subfield[@code='a']='publication'">
                    <resourceType><xsl:attribute name="resourceTypeGeneral">Text</xsl:attribute><xsl:value-of select="subfield[@code='b']"/></resourceType>
                </xsl:when>
                <xsl:when test="subfield[@code='a']='poster'">
                    <resourceType><xsl:attribute name="resourceTypeGeneral">Text</xsl:attribute>Poster</resourceType>
                </xsl:when>
                <xsl:when test="subfield[@code='a']='presentation'">
                    <resourceType><xsl:attribute name="resourceTypeGeneral">Text</xsl:attribute>Presentation</resourceType>
                </xsl:when>
                <xsl:when test="subfield[@code='a']='dataset'">
                    <resourceType><xsl:attribute name="resourceTypeGeneral">Dataset</xsl:attribute></resourceType>
                </xsl:when>
                <xsl:when test="subfield[@code='a']='image'">
                    <resourceType><xsl:attribute name="resourceTypeGeneral">Image</xsl:attribute><xsl:value-of select="subfield[@code='b']"/></resourceType>
                </xsl:when>
                <xsl:when test="subfield[@code='a']='video'">
                    <resourceType>
                        <xsl:attribute name="resourceTypeGeneral">Film</xsl:attribute>
                    </resourceType>
                </xsl:when>
                <xsl:when test="subfield[@code='a']='software'">
                    <resourceType><xsl:attribute name="resourceTypeGeneral">Software</xsl:attribute></resourceType>
                </xsl:when>
                <xsl:when test="subfield[@code='a']='lesson'">
                    <resourceType><xsl:attribute name="resourceTypeGeneral">InteractiveResource</xsl:attribute></resourceType>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <!-- 11 AlternateIdentifier -->
        <alternateIdentifiers>
            <alternateIdentifier alternateIdentifierType="URL"><xsl:value-of select="fn:eval_bibformat(controlfield[@tag=001],'&lt;BFE_RECORD_URL absolute=&quot;yes&quot; with_ln=&quot;no&quot;>')"/></alternateIdentifier>
            <xsl:for-each select="datafield[@tag=020]">
                <alternateIdentifier alternateIdentifierType="ISBN"><xsl:value-of select="subfield[@code='a']"/></alternateIdentifier>
            </xsl:for-each>
        </alternateIdentifiers>
        <!-- 12 RelatedIdentifier -->
        <xsl:if test="datafield[@tag=773]/subfield[@code='n']">
            <xsl:if test="datafield[@tag=773]/subfield[@code='n']='doi' or
                datafield[@tag=773]/subfield[@code='n']='ark' or
                datafield[@tag=773]/subfield[@code='n']='ean13' or
                datafield[@tag=773]/subfield[@code='n']='eissn' or
                datafield[@tag=773]/subfield[@code='n']='handle' or
                datafield[@tag=773]/subfield[@code='n']='isbn' or
                datafield[@tag=773]/subfield[@code='n']='issn' or
                datafield[@tag=773]/subfield[@code='n']='istc' or
                datafield[@tag=773]/subfield[@code='n']='lissn' or
                datafield[@tag=773]/subfield[@code='n']='lsid' or
                datafield[@tag=773]/subfield[@code='n']='purl' or
                datafield[@tag=773]/subfield[@code='n']='upc' or
                datafield[@tag=773]/subfield[@code='n']='url' or
                datafield[@tag=773]/subfield[@code='n']='urn'">
                <relatedIdentifiers>
                    <xsl:for-each select="datafield[@tag=773]">
                        <xsl:choose>
                            <xsl:when test="subfield[@code='n']='doi' or subfield[@code='n']='ark' or subfield[@code='n']='ean13' or subfield[@code='n']='eissn' or subfield[@code='n']='handle' or subfield[@code='n']='isbn' or subfield[@code='n']='issn' or subfield[@code='n']='istc' or subfield[@code='n']='lissn' or subfield[@code='n']='lsid' or subfield[@code='n']='purl' or subfield[@code='n']='upc' or subfield[@code='n']='url' or subfield[@code='n']='urn'">
                                <relatedIdentifier relationType="IsReferencedBy">
                                    <xsl:attribute name="relationType">
                                    <xsl:choose>
                                        <xsl:when test="subfield[@code='i']!=''"><xsl:value-of select="concat(translate(substring(subfield[@code='i'], 1,1), $LOWERCASE, $UPPERCASE), substring(subfield[@code='i'], 2))"/></xsl:when>
                                        <xsl:otherwise>IsReferencedBy</xsl:otherwise>
                                    </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:attribute name="relatedIdentifierType">
                                    <xsl:choose>
                                        <xsl:when test="subfield[@code='n']='handle'">Handle</xsl:when>
                                        <xsl:otherwise><xsl:value-of select="translate(subfield[@code='n'],$LOWERCASE,$UPPERCASE)"/></xsl:otherwise>
                                    </xsl:choose>
                                    </xsl:attribute><xsl:value-of select="subfield[@code='a']"/>
                                </relatedIdentifier>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </relatedIdentifiers>
            </xsl:if>
        </xsl:if>
        <!-- 13 Size -->
        <xsl:if test="datafield[@tag=300]">
            <sizes>
                <xsl:for-each select="datafield[@tag=300]">
                    <size><xsl:value-of select="subfield[@code='a']"/> pages</size>
                </xsl:for-each>
            </sizes>
        </xsl:if>
        <!-- 14 Format -->
        <!-- 15 Version -->
        <!-- 16 Rights -->
        <xsl:variable name="license" select="datafield[@tag=650 and @ind1=1 and @ind2=7]/subfield[@code='a']" />
        <xsl:choose>
            <xsl:when test="$license='cc-zero'">
                <rights>http://creativecommons.org/publicdomain/zero/1.0/</rights>
            </xsl:when>
            <xsl:when test="$license='cc-by'">
                <rights>http://creativecommons.org/licenses/by/4.0/</rights>
            </xsl:when>
            <xsl:when test="$license='cc-by-sa'">
                <rights>http://creativecommons.org/licenses/by-sa/4.0/</rights>
            </xsl:when>
            <xsl:when test="$license='cc-nc'">
                <rights>http://creativecommons.org/licenses/by-nc/4.0/</rights>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="datafield[@tag=542]">
                    <rights>info:eu-repo/semantics/<xsl:value-of select="datafield[@tag=542]/subfield[@code='l']"/>Access</rights>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
        <!-- 17 Description -->
        <descriptions>
            <xsl:for-each select="datafield[@tag=520]">
                <description descriptionType="Abstract">
                    <xsl:value-of select="subfield[@code='a']"/>
                </description>
            </xsl:for-each>
            <xsl:for-each select="datafield[@tag=500]">
                <description descriptionType="Other">
                    <xsl:value-of select="subfield[@code='a']"/>
                </description>
            </xsl:for-each>
        </descriptions>
    </xsl:template>
</xsl:stylesheet>
