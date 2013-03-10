<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:archimate="http://www.bolton.ac.uk/archimate"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

	<xsl:variable name="root" select="/"/>
	<xsl:variable name="templates" select="//element[@xsi:type='archimate:ArchimateDiagramModel' and property/@key='Template']"/>
	<xsl:template match="/">
		<xs:schema targetNamespace="http://magwas.rulez.org/{/archimate:model/@name}" elementFormDefault="qualified">
				<xsl:for-each select="$templates">
      		<xsl:apply-templates select="."/>
				</xsl:for-each>
		</xs:schema>
	</xsl:template>

	<xsl:template match="element[@xsi:type='archimate:ArchimateDiagramModel' and property/@key='Template']">
<!--
		<xsl:copy-of select="."/>
		<xsl:copy-of select="$objs"/>
-->
		<xsl:variable name="diagram" select="."/>
		<xsl:variable name="objs" select=".//child[@xsi:type='archimate:DiagramObject']"/>
		<!-- Specialisation relationships normally denote type inheritance, others denote template relations.
			When a specialisation is not inheritance, a property called 'attrib' must exists on it. -->
		<xsl:variable name="templaterels" select="//element[@id=$templates//sourceConnection/@relationship]"/>
		<xsl:for-each select="//element[@id=$objs/@archimateElement]">
			<xsl:variable name="element" select="."/>
			<xs:complexType>
				<xsl:attribute name="name" select="current()/@name"/>
				<xsl:variable name="diagobjs" select="$objs[@archimateElement=current()/@id]"/>
				<xsl:variable name="specrels" select="//element[@id=$diagobjs/sourceConnection/@relationship and @xsi:type='archimate:SpecialisationRelationship']"/>
				<xs:complexContent>
				<xsl:for-each select="$specrels">
					<xs:extension><xsl:attribute name="base" select="//element[@id=current()/@target]/@name"/></xs:extension>
					<!--<xsl:copy-of select="//element[@id=current()/@target]"/>-->
				</xsl:for-each>
				<xs:all>
					<xsl:for-each select="//element[@source=current()/@id and @id=$templaterels/@id]">
						<xsl:call-template name="params">
							<xsl:with-param name="element" select="$element"/>
							<xsl:with-param name="direction" select="'source'"/>
						</xsl:call-template>
					</xsl:for-each>
					<xsl:for-each select="//element[@target=current()/@id and @id = $templaterels/@id]">
						<xsl:call-template name="params">
							<xsl:with-param name="element" select="$element"/>
							<xsl:with-param name="direction" select="'target'"/>
						</xsl:call-template>
					</xsl:for-each>
				</xs:all>
				</xs:complexContent>
			</xs:complexType>
		</xsl:for-each>
  </xsl:template>

	<xsl:template name="params">
		<xsl:param name="element"/>
		<xsl:param name="direction"/>
		<xs:element>
			<xsl:choose>
				<xsl:when test="$direction='source'">
					<xsl:attribute name="name" select="//element[@id=current()/@target]/@name"/><!--FIXME more complex naming rules based on @name -->
					<xsl:attribute name="desttype" select="//element[@id=current()/@target]/@xsi:type"/><!--FIXME more complex naming rules based on @name -->
				</xsl:when>
				<xsl:when test="$direction='target'">
					<xsl:attribute name="name" select="//element[@id=current()/@source]/@name"/><!--FIXME more complex naming rules based on @name -->
					<xsl:attribute name="desttype" select="//element[@id=current()/@source]/@xsi:type"/><!--FIXME more complex naming rules based on @name -->
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="yes">Internal Error</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:attribute name="type" select="'xs:string'"/><!--FIXME define types and restrictions -->
			<xsl:attribute name="direction" select="$direction"/>
			<xsl:copy-of select="@xsi:type"/>
		<!--FIXME occurence control-->
		<!-- list of instances defined with specialisation 
			<xsl:variable name="name" select="$element/@name"/>
			<xsl:variable name="instances" select="//element[@id=//element[@xsi:type='archimate:SpecialisationRelationship' and @target=//element[@name=$name]/@id]/@source]/@name"/>
		-->
		</xs:element>
	</xsl:template>

<!--
  <xsl:template match="@*|*|text()|processing-instruction()|comment()">
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
  </xsl:template>
-->

</xsl:stylesheet>

