<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='2.0'
                xmlns="http://www.w3.org/TR/xhtml1/transitional"
								xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="#default">


<xsl:import href="/usr/share/xml/docbook/stylesheet/docbook-xsl/fo/docbook.xsl"/>

<xsl:output method="xhtml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

<xsl:param name="title.font.family">Andika</xsl:param>
<xsl:param name="sans.font.family">Andika</xsl:param>
<xsl:param name="callout.unicode.font">Andika</xsl:param>
<xsl:param name="symbol.font.family">Andika</xsl:param>
<xsl:param name="body.font.family">Andika</xsl:param>
<xsl:param name="toc.section.depth">3</xsl:param>
<xsl:param name="paper.type">A4</xsl:param>
<xsl:param name="body.font.master">8</xsl:param>
<xsl:param name="page.margin.inner">1cm</xsl:param>
<xsl:param name="page.margin.outer">1cm</xsl:param>
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

</xsl:stylesheet>


