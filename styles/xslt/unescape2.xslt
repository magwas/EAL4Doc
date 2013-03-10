<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:my="http://magwas.rulez.org/my"
	xmlns:structured="http://magwas.rulez.org/my"
>

<!--example:
<xsl:include href="unescape.xslt" />

<xsl:variable name="allowedtags">
                <securityimpact><level/></securityimpact>
                <purpose/>
                <changes/>
                <tsfichange/><from/><to/>
                <testcase/>
                <logicchanges/><file/>
</xsl:variable>

<xsl:template match="/" priority="-3">
	<a>
		<xsl:variable name="ret" select="my:unescape(//thetext/text(),$allowedtags)"/>
		<xsl:copy-of select="$ret"/>
	</a>
</xsl:template>
-->

<xsl:function name="my:unescape" as="item()*">
  <xsl:param name="str" as="item()*"/> 
  <xsl:param name="allowedtags" as="node()*"/> 
 
	<xsl:variable name="start" select="fn:substring-before($str,'&lt;')"/>
	<xsl:variable name="rest" select="fn:substring-after($str,'&lt;')"/>
	<xsl:variable name="fulltag" select="fn:substring-before($rest,'&gt;')"/>
	<xsl:variable name="tagparts" select="fn:tokenize($fulltag,'[  &#xA;]')"/>
	<xsl:variable name="ptag" select="$tagparts[1]"/>
	<xsl:variable name="tag" select="fn:replace($ptag,'^(.[^/]*)[/]*$','$1')"/>
	<xsl:variable name="aftertag" select="fn:substring-after($rest,'&gt;')"/>
	<xsl:variable name="intag" select="fn:substring-before($aftertag,fn:concat(fn:concat('&lt;/',$tag),'&gt;'))"/>
	<xsl:variable name="afterall" select="fn:substring-after($aftertag,fn:concat(fn:concat('&lt;/',$tag),'&gt;'))"/>
	<xsl:value-of select="$start"/>
	<xsl:choose>
	<xsl:when test="$tag">
		<xsl:variable name="currtag" select="$allowedtags/*[$tag = local-name()]"/>
		<xsl:if test="$currtag">
			<xsl:element name="{$currtag/local-name()}">
				<xsl:for-each select="$tagparts[position()>1]">
					<xsl:variable name="anstring" select="fn:replace(.,'^([^ &#xA;=]*)=.*$','$1')"/>
					<xsl:variable name="antag" select="$currtag/*[$anstring = local-name()]"/>
					<xsl:if test="$antag">
						<xsl:variable name="tagval" select="fn:replace(.,'^.*[^&#34;'']*[&#34;'']([^&#34;'']*)[&#34;''].*','$1')"/>
						<xsl:attribute name="{$antag/local-name()}">
							<xsl:value-of select="string($tagval)"/>
						</xsl:attribute>
					</xsl:if>
				</xsl:for-each>
				<xsl:if test="$intag">
					<xsl:copy-of select="my:unescape($intag,$allowedtags)"/>
				</xsl:if>
			</xsl:element>
		</xsl:if>
		<xsl:if test="$afterall">
			<xsl:copy-of select="my:unescape($afterall,$allowedtags)"/>
		</xsl:if>
	</xsl:when>
	<xsl:otherwise>
					<xsl:value-of select="$str"/>
	</xsl:otherwise>
	</xsl:choose>
</xsl:function>


</xsl:stylesheet>
