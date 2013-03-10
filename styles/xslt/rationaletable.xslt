<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:my="http://magwas.rulez.org/my"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:structured="http://magwas.rulez.org/my"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
	xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
	xmlns:archimate="http://www.bolton.ac.uk/archimate"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
>

<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

<xsl:param name="horizontal"/>
<xsl:param name="vertical"/>
<xsl:param name="simple">no</xsl:param>
<xsl:param name="title" select="concat($horizontal,' - ', $vertical)"/>

<xsl:variable name="root" select="/"/>

<!--
 creates a table for rationale 
	the input xml contains elements with name $horizontal and they contain elements with name $vertical
	the @name of $horizontal will be the column header
	the @name of $vertical will be the row header
	the @type of $vertical will be the cell contents where $horiontal = $vertical

-->
<xsl:template match="/">
	<xsl:choose>
		<xsl:when test="$simple = 'true'">
				<xsl:call-template name="simple"/>
		</xsl:when>
		<xsl:otherwise>
				<xsl:call-template name="normal"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="normal">
	<xsl:variable name="horizontals" select="//*[name()=$horizontal]"/>
	<xsl:variable name="verticals" select="distinct-values(//*[name()=$vertical]/@name)"/>
	<table>
	<title><xsl:value-of select="$title"/></title>
	<xsl:variable name="horizontalcount" select="count($horizontals)"/>
	<xsl:variable name="verticalcount" select="count($verticals)"/>
	<tgroup cols="{$horizontalcount+2}">
	<thead>
		<row>
		<entry/>
		<entry/>
		<xsl:for-each select="$horizontals/@name">
			<entry><xsl:value-of select="."/></entry>
		</xsl:for-each>
		</row>
	</thead>
	<tbody>
	<row>
		<entry/>
		<entry/>
		<xsl:for-each select="$horizontals">
			<xsl:variable name="count" select="count(./*[name()=$vertical])"/>
			<xsl:if test="$count=0">
			<xsl:message>
				<problem type="Zerocount" table="{$title}" name="{@name}"/>
			</xsl:message>
			</xsl:if>
			<entry><xsl:value-of select="$count"/></entry>
		</xsl:for-each>
	</row>
	<xsl:for-each select="$verticals">
		<xsl:variable name="currow" select="."/>
		<row>
			<entry>
				<xsl:copy-of select="."/>
			</entry>
			<xsl:variable name="rowcells">
				<xsl:for-each select="$horizontals">
					<entry><xsl:value-of select=".//*[name()=$vertical and @name=$currow]/@type"/></entry>
				</xsl:for-each>
			</xsl:variable>
			<entry>
				<xsl:value-of select="count($rowcells//entry/text())"/>
			</entry>
			<xsl:copy-of select="$rowcells"/>
		</row>
	</xsl:for-each>
	</tbody>
	</tgroup>
	</table>
</xsl:template>

<xsl:template name="simple">
	<table>
		<title><xsl:value-of select="$title"/></title>
		<tgroup cols="3">
			<thead>
				<row>
					<entry><xsl:value-of select="$vertical"/></entry>
					<entry>count</entry>
					<entry><xsl:value-of select="$horizontal"/></entry>
				</row>
			</thead>
			<tbody>
				<xsl:for-each select="//*[name()=$vertical]">
				<row>
					<entry><xsl:value-of select="@name"/></entry>
					<xsl:variable name="horizlist" select="./*[name()=$horizontal]/@name"/>
					<entry><xsl:value-of select="count($horizlist)"/></entry>
					<entry>
						<xsl:if test="count($horizlist)=0">
						<xsl:message>
							<problem type="Zerocount" table="{$title}" name="{@name}"/>
						</xsl:message>
						</xsl:if>
						<xsl:if test="count($horizlist)">
							<itemizedlist>
								<xsl:for-each select="$horizlist">
									<listitem>
										<xsl:value-of select="."/>
									</listitem>
								</xsl:for-each>
							</itemizedlist>
						</xsl:if>
					</entry>
				</row>
				</xsl:for-each>
			</tbody>
			</tgroup>
		</table>
</xsl:template>

</xsl:stylesheet>
