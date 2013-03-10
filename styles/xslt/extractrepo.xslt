<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

<!-- FIXME:
	- cardinality problem detection,
	- different attributes leading to same type through same relation
	- attributes inherited
-->
	<xsl:param name="xsd"/>

	<xsl:variable name="policy" select="document($xsd)"/>
	<xsl:variable name="root" select="/"/>

	<xsl:template match="/">
		<xsl:for-each select="$policy//xs:complexType">
			<xsl:message select="@name"/>
			<xsl:result-document href="tmp/repo_{@name}.xml">
			<collection>
			<xsl:copy-of select="@name"/>
			<xsl:variable name="typedef" select="."/>
			<xsl:variable name="instances">
			<set>
				<xsl:attribute name="name" select="@name"/>
				<xsl:call-template name="specialisationpicker"/>
				<xsl:call-template name="folderpicker"/>
			</set>
			</xsl:variable>
			<xsl:for-each select="$instances//element">
				<instance>
					<xsl:variable name="element" select="."/>
					<xsl:copy-of select="@id"/>
					<xsl:copy-of select="@name"/>
<!--
					<xsl:copy-of select="$typedef"/>
					<xsl:copy-of select="."/>
-->
					<xsl:for-each select="$typedef//xs:element">
						<ref>
							<xsl:copy-of select="@id"/>
							<xsl:copy-of select="@name"/>
							<xsl:if test="$element/property[@key=current()/@name]">
								<xsl:for-each select="$element/property[@key=current()/@name]/@value">
									<value>
										<xsl:attribute name="name" select="."/>
									</value>
								</xsl:for-each>
							</xsl:if>
							<xsl:call-template name="extractref">
								<xsl:with-param name="element" select="$element"/>
							</xsl:call-template>
						</ref>
					</xsl:for-each>
				</instance>
			</xsl:for-each>
			</collection>
			</xsl:result-document>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="extractref">
		<xsl:param name="element"/>
			<xsl:choose>
				<xsl:when test="@direction='source'">
					<xsl:for-each select="$root//element[@id=$root//element[@source=$element/@id and @xsi:type=current()/@xsi:type]/@target and @xsi:type=current()/@desttype]">
						<value>
						<xsl:copy-of select="@id"/>
						<xsl:copy-of select="@name"/>
						</value>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@direction='target'">
					<xsl:for-each select="$root//element[@id=$root//element[@target=$element/@id and @xsi:type=current()/@xsi:type]/@source and @xsi:type=current()/@desttype]">
						<value>
						<xsl:copy-of select="@id"/>
						<xsl:copy-of select="@name"/>
						</value>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="yes">
					<xsl:value-of select="@direction"/>
						Internal Error
					</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:template>

	<xsl:template name="specialisationpicker">
			<xsl:copy-of select="$root//element[@id=$root//element[@target=$root//element[@name=current()/@name]/@id and @xsi:type='archimate:SpecialisationRelationship']/@source]"/>
	</xsl:template>

	<xsl:template name="folderpicker">
			<xsl:copy-of select="$root//folder[property[@key='associatedObjectClass' and @value=current()/@name]]//element"/>
	</xsl:template>

</xsl:stylesheet>

