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
                        <xsl:for-each select="$tsfhierarchy//TSFI//ef/*">
                        <member>
                                <xsl:copy-of select="@name"/>
                                <xsl:attribute name="type" select="'+'"/>
                                <xsl:copy-of select="sfr"/>
                        </member>
                        </xsl:for-each>
                </eflist>
        </xsl:variable>


	<xsl:include href="dependencies.xslt" />
	<xsl:include href="unescape.xslt" />
	<xsl:include href="ht2docbook.xslt" />
	<xsl:include href="rationaletable.xslt" />

<xsl:template match="/" >

	<xsl:result-document href="generated/deps.xml"> <xsl:copy-of select="$tsfhierarchy"/> </xsl:result-document>
	<xsl:result-document href="err.FSP"><xsl:call-template name="checkdoc"/></xsl:result-document>

	<article>
		<title>Funkcionális specifikáció</title>
		<xsl:call-template name="summary"/>
		<xsl:apply-templates select="$tsfhierarchy/doc" mode="toeplan-html"/>
                <section><title>SFR - TSFI</title>
                        <xsl:call-template name="rationaletable">
                                <xsl:with-param name="horizontal" select="$sfrlist/sfrlist"/>
                                <xsl:with-param name="vertical" select="$eflist/eflist"/>
                        </xsl:call-template>
                </section>
	</article>

</xsl:template>

<xsl:template name="summary">
	<section>
		<title>Enforcing modules</title>
		<itemizedlist>
			<xsl:for-each select="$tsfhierarchy//TSFI">
				<listitem>
				<xsl:value-of select="this/archimate:ApplicationInterface/@name"/> : <xsl:value-of select="count(ef/member)"/>
				</listitem>
			</xsl:for-each>
		</itemizedlist>
	</section>
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
			<xsl:apply-templates select="*[@kind='function']|*[@kind='class']"  mode="toeplan-html"/>
		</itemizedlist>
	</section>
</xsl:template>

<xsl:template match="sup" mode="toeplan-html">
	<xsl:if test="*[@kind='function' or @kind='class']">
		<section><title>Supporting modules</title>
		<itemizedlist>
			<xsl:apply-templates select="*[@kind='function']|*[@kind='class']"  mode="toeplan-html"/>
		</itemizedlist>
		</section>
	</xsl:if>
</xsl:template>

<xsl:template match="this" mode="toeplan-html">
	<xsl:message terminate="yes">THIS<xsl:copy-of select=".."/></xsl:message>
</xsl:template>

<xsl:template match="TSFS" mode="toeplan-html">
	<!-- do nothing -->
	<!--
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
					<th>metódus</th>
					<th>paraméterek</th>
					<th>visszatérési érték</th>
					<th>tevékenység</th>
					<th>hibakezelés</th>
					<th>napló</th>
				</tr>
				<xsl:for-each select="distinct-values(//subtsf/ef/*/@id)">
					<xsl:variable name="cur" select="$tsfhierarchy//*[@id=current()]"/>
					<tr>
						<td><xsl:value-of select="$cur/../../../this/*/@name"/></td>
						<xsl:apply-templates mode="funcrow" select="$cur[1]">
							<xsl:with-param name="checkcontract" select="true()"/>
						</xsl:apply-templates>
					</tr>
				</xsl:for-each>
			</table>
		</section>
	</section>
	-->
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
			(<xsl:value-of select="substring-after(location[1]/@bodyfile,'source/')"/>) <!-- FIXME workaround -->
</xsl:template>

<xsl:template match="*" mode="digtsf">
	<xsl:message terminate="yes">
		NO rule for <xsl:value-of select="local-name()"/>
	</xsl:message>
</xsl:template>

<xsl:template match="member" mode="digtsf">
	<xsl:param name="sofar"><id>0</id></xsl:param><!--easier than check for the no id so far case-->
	<xsl:variable name="cur" select="."/>
	<xsl:variable name="myfar">
		<xsl:copy-of select=".//tsf|.//sfr|.//audit"/>
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


<xsl:template match="TSFIS" mode="toeplan-html">
	<section>
		<anchor id="funcspec"/>
		<title> Funkcionális specifikáció </title>
		<xsl:apply-templates select="*|text()|processing-instruction()|comment()"  mode="toeplan-html"/>
	<!--
		<section><title>Összefoglalás</title>
			<table class="summarytable">
				<tr>
					<th>TSFI</th>
					<th>tsf</th>
					<th>SFR</th>
					<th>metódus</th>
					<th>paraméterek</th>
					<th>visszatérési érték</th>
					<th>tevékenység</th>
					<th>hibakezelés</th>
					<th>napló</th>
				</tr>
				<xsl:for-each select="distinct-values(//TSFI/ef/*/@id)">
					<xsl:variable name="cur" select="$tsfhierarchy//*[@id=current()]"/>
					<tr>
						<td><xsl:value-of select="$cur[1]/tsfi"/></td>
						<xsl:apply-templates mode="funcrow" select="$cur[1]"/>
					</tr>
				</xsl:for-each>
			</table>
		</section>
	-->
	</section>
</xsl:template>

<xsl:template match="TSFI" mode="toeplan-html">
	<section>
	<title> <xsl:value-of select="this/*/@name"/> </title>
	<para>
		<xsl:apply-templates select="this/*/documentation" mode="unescapetodocbook"/>
	</para>
	<xsl:variable name="ef" select="ef"/>
	<xsl:for-each select="distinct-values(ef/member/@parent)">
		<section><title><xsl:value-of select="."/></title>
			<xsl:apply-templates select="$doxyobjs//component[@name=current()]/detaileddescription"/>
			<xsl:if test="$doxyobjs//component[@name=current()]//requiresauth">
				<para>
					Használatához authentikáció szükséges.
				</para>
			</xsl:if>
			<xsl:for-each select="$ef//member[@parent=current()]">
				<section><title><xsl:value-of select="@name"/></title>
					<xsl:call-template name="funcrow"/>
				</section>
			</xsl:for-each>
		</section>
	</xsl:for-each>
	</section>
</xsl:template>

<xsl:template name="funcrow">
	<xsl:copy-of select=".//briefdescription[1]"/>
	<para>
		Dokumentáció: <xsl:call-template name="funclink"/>
	</para>
	<xsl:if test=".//authorisation">
		<para>
			Hozzáférésvezérlést végez. A felhasználót, annak szerepköreit és sikertelen hozzáféréseket naplózza.
		</para>
	</xsl:if>
	<xsl:if test=".//requiresauth">
		<para>
			Használatához authentikáció szükséges.
		</para>
	</xsl:if>
	<para>
		A művelet eléréséhez az alábbi jogosultságok valamelyike szükséges:
		<xsl:variable name="classperm" select="$doxyobjs//member[@parent=current()/@parent and @name='__construct ()']//classauth"/>

		<xsl:choose>
			<xsl:when test=".//permission,$classperm">
				<itemizedlist>
					<xsl:for-each select=".//permission,$classperm">
						<listitem>
						<xsl:value-of select="."/>
						</listitem>
					</xsl:for-each>
				</itemizedlist>
			</xsl:when>
			<xsl:when test=".//nopermission">
				Nem szükséges jogosultságellenőrzés.
			</xsl:when>
			<xsl:when test=".//loggedin">
				Minden bejelentkezett felhasználó elérheti.
			</xsl:when>
			<xsl:otherwise>
				<emphasis role="problem">NO Permission check</emphasis>
				<problem type="no permission check" table="{@parent}" name="{@name}"/>
			</xsl:otherwise>
		</xsl:choose> <!--SFR-->
	</para>
	<xsl:variable name="allstuff">
		<xsl:apply-templates mode="digtsf" select="."/>
	</xsl:variable>
	<para>
		TSF(ek): <xsl:value-of select="string-join(distinct-values($allstuff//tsf),', ')"/>
	</para>
	<para>
			SFR(ek):
	<xsl:choose>
		<xsl:when test="$allstuff//sfr">
			<xsl:value-of select="string-join(distinct-values($allstuff//sfr),', ')"/>
		</xsl:when>
		<xsl:otherwise>
			<emphasis role="problem">NO SFR</emphasis>
				<problem type="no SFR" table="{@parent}" name="{@name}"/>
		</xsl:otherwise>
	</xsl:choose> <!--SFR-->
	</para>
	<xsl:apply-templates select="detaileddescription"/>
	<para>
		Kontraktus:
	<xsl:choose>
		<xsl:when test=".//argsstring = '(bool?xml)'">
			A .net keretrendszer végzi.
		</xsl:when>
		<xsl:when test="(.//argsstring = '()') and not (.//formparam)">
			Nem szükséges.
		</xsl:when>
		<xsl:when test=".//contract">
			<xsl:value-of select=".//contract[1]"/>
		</xsl:when>
		<xsl:otherwise>
			<emphasis role="problem">
				NO Contract
				<problem type="no contract" table="{@parent}" name="{@name}"/>
			</emphasis>
		</xsl:otherwise>
	</xsl:choose> <!--paraméterek-->
	</para>
	<xsl:if test=".//handleerror">
		<para>
			A kivételeket hibalapokkal jeleníti meg.
		</para>
	</xsl:if>
		<para>
			Hibakezelés:
			<xsl:variable name="allerror">
				<xsl:for-each select=".//error">
					<err>
					<name><xsl:value-of select="cause"/>:<xsl:value-of select="value"/></name>
					<tr><td>
						<xsl:value-of select="cause"/>
					</td><td>
						<xsl:value-of select="value"/>
					</td></tr>
					</err>
				</xsl:for-each>
			</xsl:variable>
			<table><tr><th>Esemény</th><th>Kezelés</th></tr>
				<xsl:for-each select="distinct-values($allerror//name)">
					<xsl:copy-of select="$allerror//err[name=current()][1]/tr"/>
				</xsl:for-each>
			</table>
		</para>
	<!--
	<xsl:if test=".//error">
	</xsl:if>
	<xsl:if test=".//audit">
	</xsl:if>
	-->
		<para>
			A következő eseményeket naplózza:
			<itemizedlist>
				<xsl:for-each select="distinct-values($allstuff//audit)">
					<listitem>
						<xsl:value-of select="."/>
					</listitem>
				</xsl:for-each>
			</itemizedlist>
		</para>
	<xsl:if test=".//webservice">
		<para>
			Webservice tulajdonságok:
			<itemizedlist>
				<xsl:for-each select=".//webservice">
					<listitem>
						<xsl:value-of select="."/>
					</listitem>
				</xsl:for-each>
			</itemizedlist>
		</para>
	</xsl:if>
	<xsl:if test=".//nocache">
		<para>
			Az oldal nem cache-elhető.
		</para>
	</xsl:if>
	<xsl:if test=".//acceptverbs">
		<para>
			Felhasználható http metódusok: <xsl:value-of select=".//acceptverbs"/>
		</para>
	</xsl:if>
	<xsl:if test=".//webmethod">
		<para>
			Web metódus a következő paraméterekkel: <xsl:value-of select=".//webmethod"/>
		</para>
	</xsl:if>
	<xsl:if test=".//antiforgery">
		<para>
			CSRF védelemmel ellátva
		</para>
	</xsl:if>
	<xsl:if test=".//httpget">
		<para>
			GET http metódussal hívható.
		</para>
	</xsl:if>
	<xsl:if test=".//jquerypartial">
		<para>
			JSON protokollt használó Ajax szolgáltatás.
		</para>
	</xsl:if>
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
