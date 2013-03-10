<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='2.0'
                xmlns="http://www.w3.org/TR/xhtml1/transitional"
								xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="#default">


<xsl:import href="/usr/share/xml/docbook/stylesheet/docbook-xsl/xhtml/docbook.xsl"/>

<xsl:output method="xhtml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

<xsl:param name="rowlimit">0</xsl:param>
<xsl:param name="difflinkbase"/>
<xsl:param name="buglinkbase"/>
<xsl:param name="loglinkbase"/>
<xsl:param name="doxylinkbase"/>
<xsl:param name="toc.section.depth">3</xsl:param>
<xsl:param name="html.stylesheet">structured.css</xsl:param>
<xsl:param name="generate.toc">
appendix  toc,title
article/appendix  nop
article   toc,title,figure
book      toc,title,figure,table,example,equation
chapter   toc,title
part      toc,title
preface   toc,title
qandadiv  toc
qandaset  toc
reference toc,title
sect1     toc
sect2     toc
sect3     toc
sect4     toc
sect5     toc
section   toc
set       toc,title
</xsl:param>
<!-- Add other variable definitions here -->

<xsl:template match="ulink[@role='doxylink']">
		<a class="doxylink"> 
		<xsl:attribute name="href" select="concat($doxylinkbase,@url)"/>
		<xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
		</a> 
</xsl:template>

<xsl:template match="link[@role='loglink']">
		<a class="loglink"> 
		<xsl:attribute name="href" select="concat($loglinkbase,@linkend)"/>
		<xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
		</a> 
</xsl:template>

<xsl:template match="link[@role='buglink']">
		<a class="buglink"> 
		<xsl:attribute name="href" select="concat($buglinkbase,@linkend)"/>
		<xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
		</a> 
</xsl:template>

<xsl:template match="link[@role='difflink']">
		<a class="difflink"> 
		<xsl:attribute name="href" select="concat($difflinkbase,@linkend)"/>
		<xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
		</a> 
</xsl:template>

<xsl:template match="anchor">
		<a>
		<xsl:copy-of select="@id"/>
		<xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
		</a> 
</xsl:template>

</xsl:stylesheet>
