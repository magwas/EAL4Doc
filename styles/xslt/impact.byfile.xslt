<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:my="http://magwas.rulez.org/my"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:param name="rowlimit" select="0"/>
	<xsl:param name="diffile"/>

	<xsl:variable name="maxstable" select="concat(//foo/@maxstable,'/')"/>

  <xsl:template match="foo">
	<book id="impact.byfile">
		<title>Hatáselemzés </title>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
	</book>
	<xsl:result-document href="{$diffile}">
	<book id="diff">
		<title>Diff</title>
	<xsl:apply-templates select="document('../../tmp/diffandlines.xml')"/>
	</book>
	</xsl:result-document>
  </xsl:template>

	<xsl:template match="impact">
	<chapter>
		<title><xsl:value-of select="@module"/> alrendszer</title>
		<para>Régi verzió: <xsl:value-of select="@latestcertified"/> (r<xsl:value-of select="@latestrev"/>)</para>
		<para>Friss verzió: <xsl:value-of select="@freshestsrc"/> (r<xsl:value-of select="@freshestrev"/>)</para>
      		<xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
	</chapter>
	</xsl:template>

	<xsl:template match="target">
	<section>
		<xsl:variable name="path" select="@path"/>
			<title><link role="difflink" linkend="{$path}"><xsl:value-of select="$path"/></link></title>
		<xsl:choose>
			<xsl:when test="$rowlimit > 0">
		    <xsl:apply-templates select="unboundcommits"/>
				<xsl:for-each select="module">
		      		<xsl:apply-templates select="."/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<table width="100%">
					<title><xsl:value-of select="$path"/></title>
					<tgroup cols='9' align='left' colsep='1' rowsep='1'>
						<colspec colwidth="50pt"/>
						<colspec colwidth="50pt"/>
						<colspec colwidth="200pt"/>
						<colspec colwidth="20pt"/>
						<colspec colwidth="20pt"/>
						<colspec colwidth="20pt"/>
						<colspec colwidth="20pt"/>
						<colspec colwidth="20pt"/>
						<colspec colwidth="20pt"/>
						<colspec colwidth="20pt"/>
						<thead> <row>
							<entry>Fájl</entry>
							<entry>modul</entry>
							<entry>módosítások</entry>
							<entry>hibajegyek</entry>
							<entry>testcase</entry>
							<entry>TOE interfész</entry>
							<entry>TSF,tsf</entry>
							<entry>SFR</entry>
							<entry>hatás</entry>
						</row> </thead>
						<tbody>
				<row>
							<entry><link role="difflink" linkend="{$path}"><xsl:value-of select="$path"/></link></entry>
		      		<xsl:apply-templates select="unboundcommits"/>
				</row>
				<xsl:for-each select="module">
					<row>
						<entry/>
		      		<xsl:apply-templates select="."/>
					</row>
				</xsl:for-each>
						</tbody>
					</tgroup>
				</table>
			</xsl:otherwise>
		</xsl:choose>
	</section>
	</xsl:template>

	<xsl:template name="normalizedtext">
		<xsl:variable name="text" select="normalize-space(.)"/>
		<xsl:if test="$text">
			<listitem><xsl:value-of select="$text"/></listitem>
		</xsl:if>
	</xsl:template>

<!--
					<entry>
						<xsl:variable name="list">
							<xsl:for-each select="distinct-values(.//msg)">
								<xsl:call-template name="normalizedtext"/>
							</xsl:for-each>
						</xsl:variable>
						<xsl:if test="count($list/listitem)">
							<itemizedlist>
								<xsl:copy-of select="$list"/>
							</itemizedlist>
						</xsl:if>
					</entry>
-->
	
	<xsl:function name="my:listofthings">
		<xsl:param name="title"/>
		<xsl:param name="stuff"/>
		<xsl:copy-of select="my:listofthings($title,$stuff,'no')"/>
	</xsl:function>

	<xsl:function name="my:listofthings">
		<xsl:param name="title"/>
		<xsl:param name="stuff"/>
		<xsl:param name="nonormalize" as='xs:string?'/>
		<xsl:variable name="list">
			<xsl:choose>
				<xsl:when test="$nonormalize = 'true'">
					<xsl:copy-of select="$stuff"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="distinct-values($stuff)">
						<xsl:call-template name="normalizedtext"/>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$rowlimit > 0">
				<xsl:if test="count($list/listitem)">
					<varlistentry>
						<term>
							<xsl:copy-of select="$title"/>
						</term>
						<listitem>	
							<itemizedlist>
								<xsl:copy-of select="$list"/>
							</itemizedlist>
						</listitem>
					</varlistentry>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<entry>
					<xsl:if test="count($list/listitem)">
						<itemizedlist>
							<xsl:copy-of select="$list"/>
						</itemizedlist>
					</xsl:if>
				</entry>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:template name="theimpact">
					<xsl:copy-of select="my:listofthings('módosítások',.//msg)"/>
					<xsl:variable name="bugs">
						<xsl:for-each select=".//bug">
						<listitem><link role="buglink" linkend="bug_{@id}"><xsl:value-of select="concat(@id,': ',@name)"/></link></listitem>
						</xsl:for-each>
					</xsl:variable>
					<xsl:copy-of select="my:listofthings('hibajegyek',$bugs/listitem,'true')"/>
					<xsl:copy-of select="my:listofthings('testcase',.//testcase/@casename)"/>
					<xsl:copy-of select="my:listofthings('TOE interface',.//tsfi)"/>
					<xsl:copy-of select="my:listofthings('TSF',.//tsf)"/>
					<xsl:copy-of select="my:listofthings('SFR',.//sfr)"/>
					<xsl:variable name="impact">
						<listitem>(biztonsági hatás)<xsl:apply-templates select=".//securityimpact[last()]"/></listitem>
						<xsl:for-each select=".//bug/tsfichange">
						<listitem><xsl:apply-templates select="."/></listitem>
						</xsl:for-each>
						<xsl:for-each select=".//bug/logicchanges">
						<listitem><xsl:apply-templates select="."/></listitem>
						</xsl:for-each>
					</xsl:variable>
					<xsl:copy-of select="my:listofthings('Hatás',$impact,'true')"/>
	</xsl:template>

	<xsl:template match="securityimpact">
		<para>
			<variablelist>
				<varlistentry>
					<term>A módosítás biztonsági hatása:</term>
					<listitem><xsl:value-of select="level"/></listitem>
				</varlistentry>
			</variablelist>
			<xsl:value-of select="text()"/>
		</para>
	</xsl:template>

	<xsl:template match="tsfichange">
		<para>
			Módosult tsfi
			<variablelist>
				<varlistentry>
					<term>régi állapot</term>
					<listitem><xsl:value-of select="from"/></listitem>
				</varlistentry>
				<varlistentry>
					<term>új állapot</term>
					<listitem><xsl:value-of select="to"/></listitem>
				</varlistentry>
			</variablelist>
			<xsl:value-of select="text()"/>
		</para>
	</xsl:template>

	<xsl:template match="logicchanges"> <!--FIXME: csak azokon a file-okon, amelyek fel vannak sorolva -->
		<para>
					A módosítás hatása a játéklogikára: <xsl:value-of select="text()"/>
		</para>
	</xsl:template>

	<xsl:template match="module|unboundcommits">
		<xsl:choose>
			<xsl:when test="$rowlimit > 0">
				<xsl:variable name="varlistentries">
					<xsl:call-template name="theimpact"/>
				</xsl:variable>
				<xsl:if test="count($varlistentries/varlistentry)">
				<variablelist>
						<title>
							<xsl:choose>
								<xsl:when test="member">
								<xsl:value-of select="concat(member[1]/@parent,'::',member[1]/@name)"/>
								</xsl:when>
							<xsl:otherwise>
								Class-wise commits
							</xsl:otherwise>
							</xsl:choose>
						</title>
						<xsl:copy-of select="$varlistentries"/>
				</variablelist>
				</xsl:if>

			</xsl:when>
			<xsl:otherwise>
					<entry>
						<xsl:if test="member">
							<xsl:value-of select="concat(member[1]/@parent,'::',member[1]/@name)"/>
						</xsl:if>
					</entry>
					<xsl:call-template name="theimpact"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

  <xsl:template match="author|date" mode="commitlog bugs">
	</xsl:template>

  <xsl:template match="msg" mode="bugs">
	</xsl:template>

  <xsl:template match="bug" mode="commitlog">
	</xsl:template>

  <xsl:template match="commit" mode="commitlog bugs">
      <xsl:apply-templates select="*|text()|processing-instruction()|comment()" mode="#current"/>
	</xsl:template>

  <xsl:template match="logentry" mode="commitlog bugs">
		<listitem>
      <xsl:apply-templates select="*|text()|processing-instruction()|comment()" mode="#current"/>
		</listitem>
	</xsl:template>


  <xsl:template match="patchfile">
		<chapter><title><xsl:value-of select="@name"/></title><anchor id="{@name}"/>
      <xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
		</chapter>
  </xsl:template>

  <xsl:template match="thediff">
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
  </xsl:template>

  <xsl:template match="diff">
		<xsl:for-each select="new|old|modified">
		<xsl:if test="member">
			<para><xsl:value-of select="concat(upper-case(substring(name(),1,1)),substring(name(), 2))"/> methods
				<itemizedlist>
					<xsl:for-each select="member">
						<listitem><xsl:value-of select="concat(@parent,'::',@name)"/></listitem>
					</xsl:for-each>
				</itemizedlist>
			</para>
		</xsl:if>
		</xsl:for-each>

			<xsl:choose>
				<xsl:when test="(0 = $rowlimit) or ($rowlimit >= count(.//line))">
		<table><title><anchor id="{ancestor::patchfile/@name}:{@newfrom}"/><xsl:value-of select="concat(ancestor::patchfile/@name,'@',@newfrom,'-',@newfrom+@newlen)"/></title>
		<tgroup cols="4">
				<colspec colwidth="20pt"/>
				<colspec colwidth="20pt"/>
				<colspec colwidth="12pt"/>
				<colspec colwidth="400pt"/>
		<thead><row>
			<entry>Line</entry>
			<entry>Commit</entry>
			<entry>Type</entry>
			<entry>Row</entry>
		</row></thead><tbody>
     		 <xsl:apply-templates select="*"/>
		</tbody></tgroup></table>
Revision number for deleted rows is incorrect.
				</xsl:when>
				<xsl:otherwise>
			<para>too much (<xsl:value-of select="count(.//line)"/>) lines, not showing</para>
				</xsl:otherwise>
			</xsl:choose>
  </xsl:template>

  <xsl:template match="line">
		<row>
			<entry><xsl:value-of select="@newlineno"/></entry>
			<entry><xsl:value-of select="@revision"/></entry>
			<entry><xsl:value-of select="@type"/></entry>
			<entry><code><xsl:value-of select="text()"/></code></entry>
		</row>
  </xsl:template>

  <xsl:template match="patch">
		<section><title><xsl:value-of select="concat(../@name,':',diff/@newfrom,'-',diff/@newfrom + diff/@newlen)"/></title>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</section>
  </xsl:template>


  <xsl:template match="@*|*|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

