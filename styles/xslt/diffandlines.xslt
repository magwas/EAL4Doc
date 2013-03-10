<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:my="http://magwas.rulez.org/my"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:variable name="blame" select="document('../../tmp/blaming.xml')"/>
	<xsl:variable name="newdoxy" select="document('../../tmp/inputs/doxy.freshestsrc.xml')"/>
	<xsl:variable name="olddoxy" select="document('../../tmp/inputs/doxy.latestcertified.xml')"/>

	<!--<xsl:variable name="maxstable" select="concat($blame//blaming/@maxstable,'/')"/>-->

  <xsl:template match="@*|*|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>

	
  <xsl:template match="line">
		<xsl:param name="target" tunnel="yes"/>
    <xsl:copy>
			<!--<xsl:copy-of select="$target//entry[@line-number=current()/@newlineno]/commit/@revision"/>-->
			<xsl:variable name="entry" select="$target//entry[@line-number=current()/@newlineno]"/>
			<xsl:variable name="commit" select="if ($entry/merged) then $entry/merged/commit else $entry/commit"/>
			<xsl:copy-of select="$commit/@revision"/>

      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="patchfile">
<!--
			EE<xsl:value-of select="current()/@name"/>DD
			AA<xsl:copy-of select="$target"/>AA
-->
    <xsl:copy>
      <xsl:apply-templates select="*|@*">
				<xsl:with-param tunnel="yes" name="target" select="$blame//target[@path = current()/@name]"/>
			</xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

<!-- 
from 
http://www.xsltfunctions.com/xsl/functx_value-intersect.html
and 
http://www.xsltfunctions.com/xsl/functx_value-except.html
-->

<xsl:function name="my:value-except" as="xs:anyAtomicType*">
	<xsl:param name="arg1" as="xs:anyAtomicType*"/> 
	<xsl:param name="arg2" as="xs:anyAtomicType*"/> 
	<xsl:sequence select="distinct-values($arg1[not(.=$arg2)])"/>
</xsl:function>

<xsl:function name="my:value-intersect" as="xs:anyAtomicType*"> 
	<xsl:param name="arg1" as="xs:anyAtomicType*"/> 
	<xsl:param name="arg2" as="xs:anyAtomicType*"/> 
	<xsl:sequence select="distinct-values($arg1[.=$arg2])"/>
</xsl:function>

  <xsl:template match="diff">
    <xsl:copy>
      <xsl:apply-templates select="*|@*"/>
			<xsl:variable name="target" select="ancestor::patchfile/@name"/>
			<xsl:variable name="ps" select="xs:integer(current()/@newfrom) + 3"/>
			<xsl:variable name="pe" select="xs:integer(current()/@newfrom + current()/@newlen) - 4"/>
			<xsl:variable name="new" select="$newdoxy//member[
					@location = $target and 
					(
						if (xs:integer(location[1]/@bodyend) eq -1 )
					  then
							(xs:integer(location[1]/@bodystart) ge $ps) and
							(xs:integer(location[1]/@bodystart) le $pe) 
					  else 	
						 ((xs:integer(location[1]/@bodystart) ge $ps) and 
						  (xs:integer(location[1]/@bodyend) le $pe)) or
						 ((xs:integer(location[1]/@bodystart) lt $ps) and 
						  (xs:integer(location[1]/@bodyend) gt $ps)) 
						
					)
				 ]"/>
			<xsl:variable name="ps" select="xs:integer(current()/@oldfrom) + 3"/>
			<xsl:variable name="pe" select="xs:integer(current()/@oldnewfrom + current()/@newlen) - 4"/>
			<xsl:variable name="old" select="$olddoxy//member[
					@location = $target and 
					(
						if (xs:integer(location[1]/@bodyend) eq -1 )
					  then
							(xs:integer(location[1]/@bodystart) ge $ps) and
							(xs:integer(location[1]/@bodystart) le $pe) 
					  else 	
						 ((xs:integer(location[1]/@bodystart) ge $ps) and 
						  (xs:integer(location[1]/@bodyend) le $pe)) or
						 ((xs:integer(location[1]/@bodystart) lt $ps) and 
						  (xs:integer(location[1]/@bodyend) gt $ps)) 
						
					)
				 ]"/>
			<new>
				<xsl:for-each select="$new[@id=my:value-except($new/@id,$old/@id)]">
					<member>
						<xsl:copy-of select="@id|@parent|@name|location"/>
					</member>
				</xsl:for-each>
			</new>
			<old>
				<xsl:for-each select="$old[@id=my:value-except($old/@id,$new/@id)]">
					<member>
						<xsl:copy-of select="@id|@parent|@name|location"/>
					</member>
				</xsl:for-each>
			</old>
			<modified>
				<xsl:for-each select="$new[@id=my:value-intersect($old/@id,$new/@id)]">
					<member>
						<xsl:copy-of select="@id|@parent|@name|location"/>
					</member>
				</xsl:for-each>
			</modified>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="patch|thediff">
    <xsl:copy>
      <xsl:apply-templates select="*|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="otherstuff">
  </xsl:template>

</xsl:stylesheet>

