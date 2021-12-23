<xsl:stylesheet version="3.0"
	xmlns:func="http://func"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<!-- 
		print all distinct subject headings to STDOUT or STDERR
		input: zml
	-->

	<xsl:template match="/">
		<xsl:variable name="subjects" select="
			fn:sort(distinct-values(
			//z:application/z:modules/z:module[
				@name = 'Object'
			]/z:moduleItem/z:repeatableGroup[
				@name = 'ObjIconographyGrp'
			]/z:repeatableGroupItem/z:vocabularyReference[
				@name = 'KeywordProjectVoc'
			]))
		" />
		<xsl:for-each select="$subjects">
			<xsl:message>
				<xsl:value-of select="."/>
			</xsl:message>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>