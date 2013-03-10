<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='2.0'
                xmlns="http://www.w3.org/TR/xhtml1/transitional"
								xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="#default">


<xsl:import href="/usr/share/xml/docbook/stylesheet/docbook-xsl/xhtml/docbook.xsl"/>

<xsl:output method="xhtml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

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

<xsl:template match="refid|webservice|handleerror|permission|required|requirement|error|cause|value|nocache|acceptverbs|httpget|jquerypartial|webmethod|antiforgery|redundant|loggedin|nopermission|xrefsect">
<!--
	<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
-->
</xsl:template>

<xsl:template match="simplesect[@kind='return']">
	Visszatérési érték: <xsl:value-of select="."/>
</xsl:template>
<xsl:template match="detaileddescription|briefdescription|sfr|tsf|tsfi">
	<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
</xsl:template>
<xsl:template match="param|returns|formparam">
	<i><xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/></i>
</xsl:template>
<xsl:template match="linebreak">
	<br/>
</xsl:template>

<xsl:template match="bold|b">
	<b><xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/></b>
</xsl:template>

<xsl:template match="authorisation">
	Hozzáférésvezérlést végez. A felhasználót, annak szerepköreit és sikertelen hozzáféréseket naplózza.<br/>
</xsl:template>

<xsl:template match="parameterlist">
	<table><tr><th>Paraméter</th><th>Leírás</th></tr>
	<xsl:apply-templates select="*"/>
	</table>
</xsl:template>
<xsl:template match="parameteritem">
	<tr><td>
	<xsl:value-of select="parameternamelist"/>
	</td><td>
	<xsl:value-of select="parameterdescription"/>
	</td></tr>
</xsl:template>

<xsl:template match="requiresauth">
	Requires authentication<br/>
</xsl:template>

<xsl:template match="ref">
	<xsl:apply-templates select="text()"/>
</xsl:template>

<xsl:template match="audit">
	A <xsl:apply-templates select="text()"/> eseményt auditálja.<br/>
</xsl:template>

</xsl:stylesheet>


