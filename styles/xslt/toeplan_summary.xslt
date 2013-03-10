<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="member">
		<xsl:copy>
			<entry>
				<xsl:copy-of select=
			</entry>
			<xsl:copy-of select="@name|@id"/>
			<xsl:copy-of select="$model//element[@id=current()/@id]/documentation"/>
			<xsl:copy-of select="$doxy//member[some $tsf in .//tsf satisfies normalize-space($tsf)=current()/@name]"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/">
		<toeplansummary>
			<xsl:apply-templates select=".//member[.//tsf]"/>
		</toeplansummary>
	</xsl:template>

</xsl:stylesheet>
