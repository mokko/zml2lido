<xsl:stylesheet 
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >
	
	<xsl:template match="/">
		<xsl:choose>
			<!-- file: seems necessary -->
			<xsl:when test="doc-available('file:vocmap.xml')">
				<xsl:message>doc available</xsl:message>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>doc NOT available</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
