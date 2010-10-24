<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns="http://www.tei-c.org/ns/1.0" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.pnp-software.com/XSLTdoc"
  exclude-result-prefixes="xs xd">

  <xsl:import href="../../../../TEI/Stylesheets/profiles/default/p4/from.xsl"/>
  <xsl:output method="xml" indent="yes"/>

  <xd:doc type="stylesheet">
    <xd:short>Converter for FreeDict.org databases: from P4 to P5</xd:short>
    <xd:detail>
      <p>The input dictionaries vary in some details, so expect to tweak this script. In some cases
        the tweaks may be worth porting back to the project, in some cases you will probably judge
        them as specific to the dictionary at hand. In general, this is going to be a one-time
        script: it should do most of the conversion work for you, and you will be left with the remaining details,
        hopefully only within the header. Please make sure to indicate in the revisionDesc that
        conversion has taken place! And then check if the FreeDict build system converts your TEI source to c5 properly.</p>
      <p>It presupposes that your working copy of Freedict starts at (SVN/)freedict/trunk/ (you
        really don't need the other directories) and that there is a copy of 
        <a href="http://tei.svn.sourceforge.net/viewvc/tei/trunk/Stylesheets/">Sebastian Rahtz's TEI
          Stylesheets</a> located in (SVN/)TEI/Stylesheets/ (this is only relevant for the xsl:import
        statement; but without that statement this script won't do its job).</p>
    </xd:detail>
    <xd:author>Piotr Bański</xd:author>
    <xd:copyright>the author(s), 2010; license: GPL v3 or any later version
      (http://www.gnu.org/licenses/gpl.html).</xd:copyright>
    <xd:svnId>$Id$</xd:svnId>
  </xd:doc>

<xd:doc>Convert trans to as many (sense/)cit as there are tr elements inside it. If the original dictionary has no sense elements under entry, create them around each old trans.</xd:doc>
  <xsl:template match="trans">
    <xsl:choose>
      <xsl:when test="parent::sense">
        <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
      </xsl:when>
      <xsl:otherwise>
        <sense>
          <xsl:if test="preceding-sibling::trans or following-sibling::trans">
            <xsl:attribute name="n"
              select="if (not(preceding-sibling::trans)) then 1 else count(preceding-sibling::trans)+1"
            />
          </xsl:if>
          <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
        </sense>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tr">
    <cit type="trans">
      <quote>
        <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
      </quote>
    </cit>
  </xsl:template>

<xd:doc>Convert gen elements *inside* trans. Be careful: this is a very specific case and you may have to tweak this template for your database (probably by removing the gramGrp layer)</xd:doc>
  <xsl:template match="gen">
    <gramGrp>
      <gen>
        <xsl:value-of select="."/>
      </gen>
    </gramGrp>
  </xsl:template>
  
  <xsl:template match="revisionDesc">
    <xsl:variable name="date" select="format-dateTime(current-dateTime(), '[Y]-[M01]-[D01]')"
      as="xs:string"/>
    <revisionDesc>
      <change when="{$date}">
        <date><xsl:value-of select="$date"/></date>
        <name>INSERT_NAME_OF_THE_CONVERTOR</name>: Conversion of TEI P4 source into P5 via tools/freedict_P4toP5.xsl; manual clean-up.</change>
      <xsl:apply-templates
        select="@*|*|comment()|processing-instruction()"/>
    </revisionDesc>
  </xsl:template>
  
  <xsl:template match="publicationStmt">
    <publicationStmt>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()"/>
      <idno type="svn">$Id:$</idno>
    </publicationStmt>
  </xsl:template>

<!-- eat the default attributes -->
  <xsl:template match="note/@anchored[.='true'] | entry/@type[.='main'] | orth/@extent[. = 'full']"
  />

</xsl:stylesheet>