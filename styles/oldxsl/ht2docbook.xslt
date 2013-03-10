<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:archimate="http://www.bolton.ac.uk/archimate"
	xmlns:structured="http://magwas.rulez.org/my"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:fn="http://www.w3.org/2005/xpath-functions">



	<xsl:template match="@*|processing-instruction()|comment()|tsf|tsfi|sfr">
		<xsl:copy>
			<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="structured|handleerror|redundant|requiresauth|antiforgery|audit|authorisation|httpget|jquerypartial|loggedin|nocache|nopermission">
	</xsl:template>

	<xsl:template match="include">
		<xsl:message>targetdir=<xsl:value-of select="$targetdir"/></xsl:message>
		<xsl:copy-of select="document(fn:concat($targetdir,'/',@file))"/>
	</xsl:template>

	<xsl:template match="*">
		<xsl:message>No match for '<xsl:value-of select="name()"/>'</xsl:message>
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="param|type|declname">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	<xsl:template match="formparam">
		<formparam>
		<xsl:apply-templates select="*"/>
		</formparam>
	</xsl:template>
	<xsl:template match="bold">
		<b>
		<xsl:apply-templates select="*"/>
		</b>
	</xsl:template>

	<xsl:template match="detaileddescription">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	<xsl:template match="parametername">
			<xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
	</xsl:template>
	<xsl:template match="parameternamelist|parameterdescription">
		<td>
			<xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
		</td>
	</xsl:template>
	<xsl:template match="parameteritem">
		<tr>
			<xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
		</tr>
	</xsl:template>
	<xsl:template match="parameterlist[@kind='param']">
		<section><title>Paraméterek:</title><table><tr><th>Név</th><th>Leírás</th></tr>
			<xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
		</table></section>
	</xsl:template>
	<xsl:template match="simplesect[@kind='return']">
		<section><title>Visszatérési érték:</title>
			<xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
		</section>
	</xsl:template>
	<xsl:template match="ref">
		<ulink url="{@refid}.html">
			<xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
		</ulink>
	</xsl:template>
	<xsl:template match="row">
		<tr>
		<xsl:apply-templates select="*"/>
		</tr>
	</xsl:template>
	<xsl:template match="entry">
		<th>
		<xsl:apply-templates select="*"/>
		</th>
	</xsl:template>
	<xsl:template match="para|itemizedlist|listitem|ulink">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</xsl:element>
	</xsl:template>
	

	<xsl:template match="table|tr|td|th">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="documentation">
		<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
	</xsl:template>

	<xsl:template match="b">
		<emphasis role="bold">
		<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</emphasis>
	</xsl:template>

	<xsl:template match="strike">
		<emphasis role="strikethrough">
		<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</emphasis>
	</xsl:template>
	
	<xsl:template match="u">
		<emphasis role="underline">
		<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</emphasis>
	</xsl:template>

	<xsl:template match="img">
		<figure>
			<mediaobject>
				<imageobject>
					<imagedata fileref="{./@src}"/>
				</imageobject>
			</mediaobject>
		</figure>
	</xsl:template>

	
	<xsl:template match="a">
		<link xlink:href="{@href}" xrefstyle="what?">
		<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</link>
	</xsl:template>

	<xsl:template match="i">
		<emphasis>
		<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</emphasis>
	</xsl:template>

	<xsl:template match="del">
		<emphasis role="strikethrough">
		<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</emphasis>
	</xsl:template>

	<xsl:template match="ul">
		<itemizedlist>
		<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</itemizedlist>
	</xsl:template>

	<xsl:template match="li">
		<listitem>
		<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</listitem>
	</xsl:template>

	<xsl:template match="br|linebreak">
		<xsl:variable name="t" select="fn:normalize-space((following-sibling::node())[1])"/>
		<xsl:variable name="l" select="local-name((following-sibling::node())[1])"/>
		<xsl:if test="('' != $t) and ($l != 'br')">
			<para/>
		</xsl:if>
	</xsl:template>


</xsl:stylesheet>


