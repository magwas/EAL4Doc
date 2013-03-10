<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:archimate="http://www.bolton.ac.uk/archimate"
	xmlns:structured="http://magwas.rulez.org/my"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:fn="http://www.w3.org/2005/xpath-functions">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>


	<xsl:param name="role" >any</xsl:param>
	<xsl:param name="flat" >true</xsl:param>
	<xsl:param name="title" />
	<xsl:param name="part" />
	<xsl:param name="noroot" select="false()"/>
	<xsl:param name="target"/>
	<xsl:param name="targetdir" />

	<xsl:include href="unescape.xslt" />
	<xsl:include href="objsfr.xslt" />
	<xsl:include href="envobj.xslt" />
	<xsl:include href="ht2docbook.xslt" />


	<xsl:template match="/">
		<xsl:variable name="unescaped">
			<xsl:apply-templates mode="unescape"/>
		</xsl:variable>
		<article lang="hu" version="5.0">
		<xsl:for-each select="$unescaped//archimate:Folder[property[@key='TOE név']]">
			<info>
				<title>
					<xsl:choose>
						<xsl:when test="$title">
							<xsl:value-of select="$title"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="./property[@key='TOE név']/@value"/>
							- Biztonsági előirányzat v<xsl:call-template name="version"/>
						</xsl:otherwise>
					</xsl:choose>
				</title>
				<pubdate><xsl:value-of select="substring-before(string(fn:current-date()),'+')"/></pubdate>
				<abstract>
					<para> Biztonsági előirányzat a <xsl:value-of select="./property[@key='TOE név']/@value"/> részére.</para>
					<para> CC megfelelőség: <xsl:value-of select="./property[@key='Common Criteria verzió']/@value"/> </para>
					<para> Készítette: <xsl:value-of select="/archimate:model/property[@key='author']/@value" /></para>
				</abstract>
			</info>
			</xsl:for-each>
			<xsl:variable name="documentable" select="$unescaped//archimate:Folder[property[@key='structured:part' and @value=$part]]"/>
				<xsl:choose>
					<xsl:when test="$noroot">
						<xsl:apply-templates select="$documentable/archimate:Folder">
							<xsl:sort select="./@name"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$documentable">
							<xsl:sort select="./@name"/>
						</xsl:apply-templates>
					</xsl:otherwise>
			</xsl:choose>
		</article>
	</xsl:template>


	<xsl:template name="version">
		<xsl:value-of select="document(concat($targetdir,'/generated/version.xml'))/info/entry/commit/@revision"/>
	</xsl:template>


	<xsl:template match="property">
		<xsl:if test="(./@key != 'structured:role') and (./@key != 'structured:part') and (./@key != 'objsfr') and (./@key != 'envobj') and (./@key != 'from-folder') and (./@key != 'objectClass') and (./@key != 'sourceLocation') and (./@key != 'deploymentLocation')" >
			<xsl:choose>
				<xsl:when test="./@key='ST címe'">
					<xsl:for-each select="//archimate:Folder[property[@key='TOE név'] and property[@key='role' and @value=$role]]">
						<tr><td>
							ST címe
						</td><td>
							<xsl:value-of select="./property[@key='TOE név']/@value"/>
							- Biztonsági előirányzat v<xsl:call-template name="version"/>
						</td></tr>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@key='ST verzió'">
					<tr><td>
						ST verzió
					</td><td>
						<xsl:call-template name="version"/>
					</td></tr>
				</xsl:when>
				<xsl:when test="@key='TOE verzió'">
					<tr><td>
						TOE verzió
					</td><td>
						<xsl:value-of select="document(concat($targetdir,'/generated/deploylist.xml'))/deploylist/assemblyversion"/>
					</td></tr>
				</xsl:when>
				<xsl:when test="./@key='Publikálás Dátuma'">
					<tr><td>
						Publikálás Dátuma
					</td><td>
						<xsl:value-of select="substring-before(string(fn:current-date()),'+')"/>
					</td></tr>
				</xsl:when>
				<xsl:when test="@key='copy-image'">
					<xsl:message>copy-image <xsl:value-of select="../@name" /></xsl:message>
					<tr><td colspan="2"><figure>
						<title><xsl:value-of select="../@name" /></title>
						<remark><xsl:apply-templates select="../documentation" /></remark>
						<mediaobject>
							<imageobject>
								<imagedata fileref="../pics/{@value}.png"/>
							</imageobject>
						</mediaobject>
					</figure></td></tr>
				</xsl:when>
				<xsl:otherwise>
					<tr><td>
						<xsl:value-of select="./@key" />
					</td><td>
						<xsl:value-of select="./@value" />
					</td></tr>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="archimate:ArchimateDiagramModel|archimate:DiagramModel|archimate:SketchModel">
		<xsl:if test="not (./property[@key='structured:role' and (@value!=$role and $role != 'any')])">
			<tr><td colspan="2">
				<figure>
					<title><xsl:value-of select="./@name" /></title>
					<remark><xsl:apply-templates select="./documentation" /></remark>
					<mediaobject>
						<imageobject>
							<imagedata fileref="../pics/{./@id}.png"/>
						</imageobject>
					</mediaobject>
				</figure>
			</td></tr>
			<xsl:apply-templates select="property"/>
		</xsl:if>
	</xsl:template>



<!--
	<xsl:template match="include">
		<xsl:message>targetdir=<xsl:value-of select="$targetdir"/></xsl:message>
		<xsl:copy-of select="document(fn:concat($targetdir,'/',@file))"/>
	</xsl:template>
-->

	<xsl:template match="archimate:*" >
		<xsl:if test="not (./property[@key='structured:role' and (@value!=$role and $role != 'any')])">
			<tr>
				<td class="starter"  valign="top"><xsl:value-of select="./@name" />
				</td>
				<td class="starter" valign="top"><xsl:apply-templates select="./documentation" /></td>
			</tr>
			<tr> <td><!--Properties--><xsl:text> </xsl:text></td><td >
				<xsl:call-template name="proptable"/>
			</td></tr>
		</xsl:if>
	</xsl:template>

	<xsl:template name="proptable">
		<xsl:variable name="props">
			<xsl:apply-templates select="property"/>
		</xsl:variable>
		<xsl:if test="string($props)">
			<table class="propertytable">
				<xsl:copy-of select="$props"/>
			</table>
		</xsl:if>
	</xsl:template>

	<xsl:template match="archimate:Folder">
		<xsl:if test="not (./property[@key='structured:role' and (@value!=$role and $role != 'any')])">
			<section>
				<title><xsl:value-of select="./@name"/></title>
				<para>
					<xsl:apply-templates select="./documentation"/>
				</para>
				<xsl:call-template name="proptable"/>
				<xsl:if test="archimate:* except archimate:Folder or property[@key='from-folder']">
					<table class="elementtable">
						<xsl:apply-templates select="archimate:ArchimateDiagramModel|archimate:DiagramModel|archimate:SketchModel">
							<xsl:sort select="./@name"/>
						</xsl:apply-templates>
						<xsl:apply-templates select="archimate:* except (archimate:ArchimateDiagramModel|archimate:DiagramModel|archimate:SketchModel|archimate:Folder)">
							<xsl:sort select="./@name"/>
						</xsl:apply-templates>
						<xsl:if test="'false'=$flat">
							<xsl:for-each select="//*[@id=current()/property[@key='from-folder']/@value]/*[@id] except (//archimate:ArchimateDiagramModel|//archimate:DiagramModel|//archimate:SketchModel|//archimate:Folder)">
								<xsl:apply-templates select=".">
									<xsl:sort select="./@name"/>
								</xsl:apply-templates>
							</xsl:for-each>
						</xsl:if>
					</table>
				</xsl:if>
				<xsl:if test="'false'=$flat">
					<xsl:if test="./property[@key='objsfr']">
						<xsl:call-template name="objsfr"/>
					</xsl:if>
					<xsl:if test="./property[@key='envobj']">
						<xsl:call-template name="envobj"/>
					</xsl:if>
				</xsl:if>
				<xsl:apply-templates select="archimate:Folder">
					<xsl:sort select="./@name"/>
				</xsl:apply-templates>
			</section>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>

