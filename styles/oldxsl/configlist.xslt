<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:archimate="http://www.bolton.ac.uk/archimate"
xmlns:fn="http://www.w3.org/2005/xpath-functions">

<xsl:output method="html" version="4.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

<xsl:param name="doxyfile"/>
<xsl:param name="targetdir"/>
<xsl:variable name="doxyobjs" select="document(fn:concat($targetdir,'/',$doxyfile))"/>
<xsl:variable name="deployobjs" select="document(fn:concat($targetdir,'/tmp/inputs/deploylist.xml'))"/>
<xsl:variable name="archiobjs" select="/"/>
<xsl:variable name="components" select="//archimate:ApplicationComponent[@id=//archimate:SpecialisationRelationship[@target=//archimate:ApplicationComponent[@name='Komponens']/@id]/@source]"/>
<xsl:variable name="subsystems" select="//archimate:*[property[@key='deploymentLocation']]"/>


<xsl:template match="/">
<!--<xsl:result-document href="subsys.xml"><xsl:copy-of select="$subsystems"/></xsl:result-document>-->
	<html><head>
		<title>Konfigurációs lista</title>
		<link rel="stylesheet" href="structured.css" type="text/css" />
		</head>
	<body>
	<ul>
		<li><a href="#src">Implementációs reprezentáció konfigurációs lista</a></li>
		<li><a href="#depl">TOE konfigurációs lista</a></li>
		<ul>
				<xsl:for-each select="$deployobjs//files/path[1]">
					<xsl:variable name="nicename" select="tokenize(substring-after(.,'deployment/'),'/')[1]"/>
					<li><a href="#{$nicename}"><xsl:value-of select="$nicename"/></a></li>
				</xsl:for-each>
		</ul>
	</ul>
	<a name="src"><h1>Implementációs reprezentáció konfigurációs lista</h1></a>
	<table>
	<tr><th>
			Configuration item
		</th><th>
			Alrendszer
		</th><th>
			Komponens
		</th><th>
			Modul
		</th><th>
			tsf
		</th><th>
			TOE interface
	</th></tr>
	<xsl:for-each select="distinct-values($doxyobjs//@location)">
		<xsl:sort select="."/>
		<xsl:variable name="path" select="string-join(tokenize(.,'FOOBAR')[position()>1],'source')"/>
		<xsl:if test="$path">
			<xsl:variable name="component" select="$components[property[@key='sourceLocation' and contains($path,@value)]]"/>
		<tr><td class="starter">
				<xsl:copy-of select="$path"/>
			</td><td class="starter"><div/>
				<xsl:value-of select="$subsystems[@id=$archiobjs//archimate:CompositionRelationship[@target=$component/@id]/@source]/@name"/>
			</td><td class="starter"><div/>
				<xsl:value-of select="$component/@name"/>
			</td><td class="starter"><div/>
				<xsl:value-of select="distinct-values($doxyobjs//*[@location=current() and @kind='class']/@name)"/>
			</td><td class="starter"><div/>
				<xsl:variable name="tsflist" select="distinct-values($doxyobjs//*[@location=current()]//tsf)"/>
				<xsl:for-each select="$tsflist">
					<xsl:variable name="tsfname" select="normalize-space(.)"/>
					<xsl:variable name="tsfobj" select="$archiobjs//archimate:ApplicationFunction[@name=$tsfname]"/>
					<xsl:variable name="rel" select="$archiobjs//archimate:AssignmentRelationship[@target=$tsfobj/@id]"/>
					<xsl:variable name="comp" select="$archiobjs//archimate:ApplicationComponent[@id=$rel/@source]"/>
					<xsl:if test="not($component = $comp)">
						<xsl:variable name="message">
							ERROR: Misplaced function <xsl:value-of select="."/> in <xsl:value-of select="$path"/>: it is <xsl:value-of select="$component/@name"/> while designed to be in  <xsl:value-of select="$comp/@name"/>
						</xsl:variable>
						<xsl:message>
							<xsl:copy-of select="$message"/>
						</xsl:message>
						<span style="background-color:red;" title="{$message}">MISPLACED: <xsl:value-of select="."/></span>
					</xsl:if>
				</xsl:for-each>
				<xsl:value-of select="string-join($tsflist,', ')"/>
			</td><td class="starter"><div/>
				<xsl:value-of select="string-join(distinct-values($doxyobjs//*[@location=current()]//tsfi),', ')"/>
		</td></tr>
		</xsl:if>
	</xsl:for-each>
	</table>
	<a name="depl"><h1>TOE konfigurációs lista</h1></a>
	<xsl:for-each select="$deployobjs//files">
		<table>
			<tr><th>
				File name
			</th><th>
				Komponens
			</th></tr>
			<xsl:for-each select="path[position()>1]">
				<tr><td>
					<xsl:value-of select="."/>
				</td><td>
					<xsl:variable name="path" select="."/>
					<xsl:variable name="items">
						<xsl:for-each select="$subsystems//property[@key='deploymentLocation']/@value">
							<xsl:if test="matches($path,current())">
								<du>
								<xsl:copy-of select="current()/../../@name"/>
								</du>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:value-of select="string-join($items/du/@name,', ')"/>
				</td></tr>
			</xsl:for-each>
		</table>
	</xsl:for-each>
	</body>
	</html>
</xsl:template>
</xsl:stylesheet>

