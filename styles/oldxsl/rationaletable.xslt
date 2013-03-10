<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:my="http://magwas.rulez.org/my"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:structured="http://magwas.rulez.org/my"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
	xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
	xmlns:archimate="http://www.bolton.ac.uk/archimate"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
>


<!--
 horizontal := <any:root><any:tag>hvalue</any:tag></any:root>
 vertical := <any:vroot><any:vtag name="vtag name" type="+ or -">//<any:tag>vvalue</any:tag><any:vtag></any:vroot>

 creates a table
 the columns of the table will be horizontal/*/hvalue
 the rows of the table will be vertical/*/@name
 if hvalue=vvalue in the same tag (by local-name()), value of vtag/@type is drawn in the corresponding cell
-->
<xsl:template name="rationaletable">
	<xsl:param name="horizontal"/>
	<xsl:param name="vertical"/>
	<table class="rationale">
		<tr>
			<th/>
			<th>sum</th>
			<xsl:for-each select="$horizontal/*">
				<th><xsl:value-of select="."/></th>
			</xsl:for-each>
		</tr>
		<xsl:variable name="table">
		<xsl:for-each select="$vertical/*">
			<xsl:variable name="curr" select="."/>
			<tr>
				<td>
				<xsl:value-of select="$curr/@name"/>
				</td>
				<td>
					<xsl:copy-of select="count(distinct-values($curr//*[local-name() = $horizontal/*/local-name()]))"/>
				</td>
				<xsl:for-each select="$horizontal/*">
					<td>
						<xsl:if test="$curr//*[local-name()=local-name(current())]/text() = string(.)">
							<xsl:attribute name="horizontal" select="."/>
							<xsl:value-of select="distinct-values($curr//@type)"/>
						</xsl:if>
					</td>
				</xsl:for-each>
			</tr>
		</xsl:for-each>
		</xsl:variable>
		<tr>
			<td>summary</td><td>/</td>
		<xsl:for-each select="$horizontal/*">
			<td>
				<xsl:variable name="count" select="count($table//td[@horizontal = current()])"/>
				<xsl:value-of select="$count"/>
				<xsl:if test="$count = 0">
					<problem type="Zerocount" table="oldbuild" name="{.}"/>
				</xsl:if>
			</td>
		</xsl:for-each>
		</tr>
		<xsl:copy-of select="$table"/>
	</table>
</xsl:template>

</xsl:stylesheet>
