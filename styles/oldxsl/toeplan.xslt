<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:archimate="http://www.bolton.ac.uk/archimate"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:fn="http://www.w3.org/2005/xpath-functions">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

	<xsl:param name="doxyfile"/>
	<xsl:param name="targetdir"/>
	<xsl:param name="pathmarker"/>

	<xsl:variable name="doxyobjs" select="document(fn:concat($targetdir,'/',$doxyfile))"/>
	<xsl:variable name="archiobjs" select="/"/>
	<xsl:variable name="tsfhierarchy">
		<xsl:call-template name="tsfhierarchy"/>
	</xsl:variable>
	<xsl:variable name="sfrlist">
		<sfrlist>
			<xsl:for-each select="distinct-values($doxyobjs//sfr/text())">
				<sfr><xsl:value-of select="."/></sfr>
			</xsl:for-each>
		</sfrlist>
	</xsl:variable>
	<xsl:variable name="eflist">
		<eflist>
			<xsl:for-each select="$tsfhierarchy//TSF//ef/*">
			<member>
				<xsl:attribute name="name" select="concat(@parent,'::',@name)"/>
				<xsl:attribute name="type" select="'+'"/>
				<xsl:copy-of select="sfr"/>
			</member>
			</xsl:for-each>
		</eflist>
	</xsl:variable>


	<xsl:include href="dependencies.xslt" />
	<xsl:include href="rationaletable.xslt" />
	<xsl:include href="unescape.xslt" />
	<xsl:include href="ht2docbook.xslt" />

<xsl:variable name="components" select="//archimate:ApplicationComponent[@id=//archimate:SpecialisationRelationship[@target=//archimate:ApplicationComponent[@name='Komponens']/@id]/@source]"/>
<xsl:variable name="subsystems" select="//archimate:ApplicationComponent[@id=//archimate:SpecialisationRelationship[@target=//archimate:ApplicationComponent[@name='Alrendszer']/@id]/@source and not(property/@key='3rdparty')]"/>

<xsl:template match="/" >

	<xsl:result-document href="generated/deps.xml"> <xsl:copy-of select="$tsfhierarchy"/> </xsl:result-document>
	<xsl:result-document href="err.dependencies"> <xsl:call-template name="checkdoc"/> </xsl:result-document>

	<article>
		<title>TOE Terv - Funkcionális specifikáció</title>
		<xsl:apply-templates select="$tsfhierarchy/doc" mode="toeplan-html"/>
		<section><title>SFR - enforcing modules</title>
			<xsl:call-template name="rationaletable">
				<xsl:with-param name="horizontal" select="$sfrlist/sfrlist"/>
				<xsl:with-param name="vertical" select="$eflist/eflist"/>
			</xsl:call-template>
		</section>
	</article>

</xsl:template>

<xsl:template match="text()|processing-instruction()|comment()" mode="toeplan-html">
		<xsl:apply-templates select="*|text()|processing-instruction()|comment()"  mode="toeplan-html"/>
</xsl:template>

<xsl:template match="*" mode="toeplan-html">
	<xsl:message terminate="yes">no match for <xsl:copy-of select="local-name()"/></xsl:message>
</xsl:template>

<xsl:template match="doc" mode="toeplan-html">
		<xsl:apply-templates select="*|text()|processing-instruction()|comment()"  mode="toeplan-html"/>
</xsl:template>

<xsl:template match="ef" mode="toeplan-html">
	<section><title>Enforcing modules</title>
		<itemizedlist>
			<xsl:apply-templates select="*[@kind='function']"  mode="toeplan-html"/>
		</itemizedlist>
	</section>
</xsl:template>

<xsl:template match="sup" mode="toeplan-html">
	<xsl:if test="*[@kind='function' or @kind='class']">
		<section><title>Supporting modules</title>
		<itemizedlist>
			<xsl:apply-templates select="*[@kind='function']"  mode="toeplan-html"/>
		</itemizedlist>
		</section>
	</xsl:if>
</xsl:template>

<xsl:template match="this" mode="toeplan-html">
	<xsl:message terminate="yes">THIS<xsl:copy-of select=".."/></xsl:message>
</xsl:template>

<xsl:template match="TSFS" mode="toeplan-html">
	<section>
		<anchor id="toedesign"/>
		<title> TOE design </title>
		<xsl:apply-templates select="*|text()|processing-instruction()|comment()"  mode="toeplan-html"/>
		<section><title>Összefoglalás</title>
			<table class="summarytable">
				<tr>
					<th>TSF</th>
					<th>subtsf</th>
					<th>SFR</th>
					<th>alrendszer</th>
					<th>metódus</th>
					<th>paraméterek</th>
					<th>visszatérési érték</th>
					<th>tevékenység</th>
					<th>hibakezelés</th>
					<th>napló</th>
				</tr>
				<xsl:for-each select="distinct-values(//subtsf/ef/*[@kind='function']/@id)">
					<xsl:variable name="cur" select="$tsfhierarchy//*[@id=current()]"/>
					<tr>
						<td><xsl:value-of select="$cur/../../../this/*/@name"/></td><!--TSF-->
						<!-- <td><xsl:value-of select="../../this/*/@name"/></td>--><!--subtsf-->
						<xsl:apply-templates mode="funcrow" select="$cur[1]">
							<xsl:with-param name="checkcontract" select="false()"/>
						</xsl:apply-templates>
					</tr>
				</xsl:for-each>
			</table>
		</section>
	</section>
</xsl:template>

<xsl:template match="documentation" mode="unescapetodocbook">
	<xsl:variable name="unescaped">
		<xsl:apply-templates select="." mode="unescape"/>
	</xsl:variable>
  <xsl:apply-templates select="$unescaped/documentation/node()"/>
</xsl:template>



<xsl:template match="TSF" mode="toeplan-html">
	<section><title><xsl:value-of select="this/*/@name"/></title>
	<para>
		<xsl:apply-templates select="this/*/documentation" mode="unescapetodocbook"/>
	</para>
	<xsl:apply-templates select="subtsf" mode="toeplan-html" />
	</section>
</xsl:template>

<xsl:template match="subtsf" mode="toeplan-html">
	<section>
	<title> <xsl:value-of select="this/*/@name"/> </title>
	<para>
		<xsl:apply-templates select="this/*/documentation" mode="unescapetodocbook"/>
	</para>
	<xsl:apply-templates select="ef"  mode="toeplan-html"/>
	<xsl:apply-templates select="sup"  mode="toeplan-html"/>
	</section>
</xsl:template>

<xsl:template name="funclink">
		<link xlink:href="{@url}" xrefstyle="what?">
			<xsl:value-of select="@parent"/>::<xsl:value-of select="@name"/>
		</link>
			(<xsl:value-of select="substring-after(location[1]/@bodyfile,'source/')"/>)<!-- FIXME workaround -->
</xsl:template>

<xsl:template match="component" mode="digtsf">
	<!-- do nothing -->
</xsl:template>
<xsl:template match="*" mode="digtsf">
	<xsl:message terminate="yes">
		NO rule for <xsl:value-of select="local-name()"/>:<xsl:copy-of select="."/>
	</xsl:message>
</xsl:template>

<xsl:template match="member" mode="digtsf">
	<xsl:param name="sofar"><id>0</id></xsl:param><!--easier than check for the no id so far case-->
	<xsl:variable name="cur" select="."/>
	<xsl:variable name="myfar">
		<xsl:copy-of select=".//tsf|.//sfr"/>
		<id><xsl:value-of select="@id"/></id>
	</xsl:variable>
	<xsl:copy-of select="$myfar"/>
<!--
	<xsl:variable name="refids" select="distinct-values(current()//references/@refid except current()/@refid except $sofar/id/text())"/>
	<xsl:for-each select="$refids">
		<xsl:apply-templates select="$doxyobjs//member[@id=current()]" mode="digtsf">
			<xsl:with-param name="sofar" select="$myfar|$sofar"/>
		</xsl:apply-templates>
	</xsl:for-each>
-->
</xsl:template>

<xsl:template match="*" mode="funcrow">
	<xsl:param name="checkcontract" select="false()"/>
	<xsl:variable name="allstuff">
		<xsl:apply-templates mode="digtsf" select="."/>
	</xsl:variable>
	<xsl:variable name="path" select="string-join(tokenize(@location,$pathmarker)[position()>1],'source')"/>
	<td>
		<xsl:value-of select="distinct-values($allstuff//tsf)"/>
	</td><!--subtsf-->
	<xsl:choose>
		<xsl:when test="$allstuff//sfr">
			<td><xsl:value-of select="distinct-values($allstuff//sfr)"/></td>
		</xsl:when>
		<xsl:otherwise>
			<td bgcolor="red">NO SFR</td>
			<problem type="no SFR" name="{@parent}::{@name}" table="{$path}"/>
		</xsl:otherwise>
	</xsl:choose> <!--SFR-->
	<td>
		<xsl:variable name="component" select="$components[property[@key='sourceLocation' and contains($path,@value)]]"/>
		<xsl:variable name="subsystem" select="$subsystems[@id=$archiobjs//archimate:CompositionRelationship[@target=$component/@id]/@source]/@name"/>
		<xsl:value-of select="$subsystem"/> / <xsl:value-of select="$component/@name"/>
<!--
<xsl:message terminate="no">
location=<xsl:value-of select="@location"/>
path=<xsl:value-of select="$path"/>
component=<xsl:value-of select="$component/@name"/>
subsystem=<xsl:value-of select="$subsystem"/>
</xsl:message>
-->

	</td><!-- alrendszer -->
	<td>
		<xsl:call-template name="funclink"/>
	</td><!--metódus-->
	<xsl:choose>
		<xsl:when test="false() = $checkcontract">
			<td><xsl:value-of select=".//argsstring"/>
			</td>
		</xsl:when>
		<xsl:when test=".//contract">
			<td><xsl:value-of select=".//argsstring"/>
			Kontraktus: <xsl:value-of select=".//contract"/>
			</td>
		</xsl:when>
		<xsl:when test=".//argsstring = '()' or .//argsstring = '(bool?xml)'">
			<td><xsl:value-of select=".//argsstring"/>
			</td>
		</xsl:when>
		<xsl:otherwise>
			<td bgcolor="red">
				<xsl:value-of select=".//argsstring"/>
				NO Contract
				<problem type="no contract" name="{@parent}::{@name}" table="{$path}"/>
			</td>
		</xsl:otherwise>
	</xsl:choose> <!--paraméterek-->
	<td><xsl:value-of select="type"/>:
	   <xsl:value-of select=".//simplesect[@kind='return']"/>
  </td><!--visszatérési érték-->
	<td><xsl:value-of select=".//briefdescription"/></td><!--tevékenység-->
	<td><xsl:value-of select=".//error"/></td><!--hibakezelés-->
	<td><xsl:value-of select=".//audit"/></td><!--hibakezelés-->
</xsl:template>

<xsl:template match="TSFIS" mode="toeplan-html">
	<section>
		<anchor id="funcspec"/>
		<title> Funkcionális specifikáció </title>
		<xsl:apply-templates select="*|text()|processing-instruction()|comment()"  mode="toeplan-html"/>
		<section><title>Összefoglalás</title>
			<table class="summarytable">
				<tr>
					<th>TSFI</th>
					<th>tsf</th>
					<th>SFR</th>
					<th>alrendszer</th>
					<th>metódus</th>
					<th>paraméterek</th>
					<th>visszatérési érték</th>
					<th>tevékenység</th>
					<th>hibakezelés</th>
					<th>napló</th>
				</tr>
				<xsl:for-each select="distinct-values(//TSFI/ef/*[@kind='function']/@id)">
					<xsl:variable name="cur" select="$tsfhierarchy//*[@id=current()]"/>
					<tr>
						<td><xsl:value-of select="$cur[1]/tsfi"/></td><!--TSF-->
						<xsl:apply-templates mode="funcrow" select="$cur[1]">
							<xsl:with-param name="checkcontract" select="true()"/>
						</xsl:apply-templates>
					</tr>
				</xsl:for-each>
			</table>
		</section>
	</section>
</xsl:template>

<xsl:template match="TSFI" mode="toeplan-html">
	<section>
	<title> <xsl:value-of select="this/*/@name"/> </title>
	<para>
		<xsl:apply-templates select="this/*/documentation" mode="unescapetodocbook"/>
	</para>
	<xsl:apply-templates select="ef"  mode="toeplan-html"/>
	<xsl:apply-templates select="sup"  mode="toeplan-html"/>
	</section>
</xsl:template>

<xsl:template match="archimate:ApplicationFunction|archimate:ApplicationComponent|archimate:ApplicationInterface" mode="toeplan-html">
	<tr><td>
	<xsl:choose>
		<xsl:when test="property[@key='id']">
	<h4>
		 <a href="{property[@key='url']/@value}"><xsl:value-of select="@name"/></a>
		</h4>
		</xsl:when>
		<xsl:otherwise>
	<h4>
		 <xsl:value-of select="@name"/>
		</h4>
	<xsl:apply-templates select="documentation" mode="unescapetodocbook"/>
		</xsl:otherwise>
	</xsl:choose>
	</td></tr>
</xsl:template>

<xsl:template match="member" mode="toeplan-html">
	<xsl:if test="@kind='function'">
	<listitem>
		<xsl:call-template name="funclink"/>
	</listitem>
	</xsl:if>
</xsl:template>

<xsl:template match="component" mode="toeplan-html">
	<xsl:if test="@kind='class'">
	<listitem>
		<xsl:call-template name="funclink"/>
	</listitem>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
