<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:my="http://magwas.rulez.org/my"
>

<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

<xsl:param name="testcases"/>

<xsl:variable name="doxy" select="/"/>

<xsl:template match="/">
	<xsl:message select="concat('testcases=',$testcases)"/>
	<xsl:variable name="testcaselist">
		<xsl:for-each select="tokenize($testcases,',')">
			<xsl:copy-of select="document(.)//testcase"/>
		</xsl:for-each>
	</xsl:variable>
	<testlist>
		<xsl:apply-templates select="$testcaselist//testcase"/>
	</testlist>
</xsl:template>

<xsl:template match="tested">
	<xsl:copy>
		<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		<xsl:variable name="parentname" select="normalize-space(string-join(tokenize(@fnname,'::')[position() &lt; last()],'::'))"/>
		<xsl:variable name="fnname" select="normalize-space(tokenize(@fnname,'::')[last()])"/>
		<xsl:variable name="memberdef" select="$doxy//member[@name=replace($fnname,'__DC__','::') and @parent=$parentname]"/>
		<xsl:if test="not($memberdef) and not(contains($fnname,'InputValidationExtensionHelper') or contains($fnname,'InputValidationHelper'))">
			<xsl:message terminate="no">
				<nocode>
					<xsl:attribute name="function" select="concat($parentname,'::',$fnname)"/>
					<xsl:attribute name="parent" select="$parentname"/>
					<xsl:attribute name="fn" select="$fnname"/>
					<xsl:attribute name="stem" select="if(contains($fnname,'(')) then substring-before($fnname,'(') else $fnname"/>
				</nocode>
			</xsl:message>
		</xsl:if>
		<xsl:copy-of select="$memberdef"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="@*|*|text()|processing-instruction()|comment()">
	<xsl:copy>
		<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
