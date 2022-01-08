<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<!-- 
		given zml input, report moduleItems with non-distinct IDs, i.e.
		where moduleItem with same ID exists multiple times. Of course,
		only moduleItems of the same type should be compared.
		
		This should not happen and mpapi should not produce this kind of 
		double.
	-->

	<xsl:template match="/">
		<xsl:for-each-group select="/z:application/z:modules/z:module" group-by=".">
			<xsl:message>
				<xsl:value-of select="@name"/>
			</xsl:message>
			<xsl:variable name="mtype" select="@name"/>
			<xsl:for-each-group select="z:moduleItem" group-by="@id">
				<xsl:if test="count(current-group())> 1">
					<xsl:message>
						<xsl:text>NOT UNIQUE </xsl:text>
						<xsl:value-of select="@id"/>
					</xsl:message>
				</xsl:if>
			</xsl:for-each-group>
		</xsl:for-each-group>
	</xsl:template>
</xsl:stylesheet>