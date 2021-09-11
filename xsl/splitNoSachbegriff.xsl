<xsl:stylesheet 
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:lido="http://www.lido-schema.org"
	xmlns:z="http://www.zetcom.com/ria/ws/module"
	exclude-result-prefixes="z">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<!--
	Split the records in two sets: those with a Sachbegriff and those without
	input: Zetcom XML (zml)
	output: Zetcom XML (zml)
	-->
	
	<xsl:template match="/">
		<!-- value exists and is not empty-->
		<!-- value doesn't exist -->
		<xsl:variable name="mitSachbegriff" select="/z:application/z:modules/z:module[@name='Object']/z:moduleItem[
			normalize-space(z:dataField[@name = 'ObjTechnicalTermClb']/z:value) ne ''
		]"/>
		<!-- 
			funktioniert nicht 
			select="/z:application/z:modules/z:module[@name='Object']/z:moduleItem[@id != $mitSachbegriff/@id]"
		<xsl:variable name="leererSachbegriff" select="/z:application/z:modules/z:module[@name='Object']/z:moduleItem[
			normalize-space(z:dataField[@name = 'ObjTechnicalTermClb']/z:value) eq ''
		]"/>
		-->

		<xsl:variable name="ohneSachbegriff" select="/z:application/z:modules/z:module[@name='Object']/z:moduleItem[
			not (z:dataField[@name = 'ObjTechnicalTermClb'])]"/>

		<!-- Gibt es DS ohne Sachbegriff, die überhaupt kein dataField[@name = 'ObjTechnicalTermClb'] haben?
			mitSachbegriff
			<xsl:value-of select="$mitSachbegriff/@id"/>
			leererSachbegriff
			<xsl:value-of select="$leererSachbegriff/@id"/>
			ohne
			<xsl:value-of select="$ohneSachbegriff/@id"/>
		-->
		<xsl:message>
			<xsl:text>mitSB: </xsl:text>
			<xsl:value-of select="count($mitSachbegriff)"/>
			<xsl:text>&#10;ohneSB: </xsl:text>
			<xsl:value-of select="count($ohneSachbegriff)"/>
			<xsl:text>&#10;gesamt: </xsl:text>
			<xsl:value-of select="count($ohneSachbegriff)+count($mitSachbegriff)"/>
			<xsl:text>&#10;ohne Sachbegriff: </xsl:text>
			<xsl:value-of select="$ohneSachbegriff/@id"/>
		</xsl:message>

		<!--We can use regular output-->
		<z:application> 
			<z:modules>
				<z:module name="Object" totalSize="{count($mitSachbegriff)}">
					<xsl:copy-of select="$mitSachbegriff"/>
				</z:module>
				<!-- copies all related records from source, not just the ones linked in the records with Sachbegriff-->
				<xsl:message>
					<xsl:text>Copying all related records of the type</xsl:text>
				</xsl:message>
				<xsl:for-each select="/z:application/z:modules/z:module[@name ne 'Object']">
					<xsl:message>
						<xsl:text>   </xsl:text>
						<xsl:value-of select="@name"/>
					</xsl:message>
					<xsl:copy-of select="."/>
				</xsl:for-each>
			</z:modules>
		</z:application>

		<xsl:result-document method="xml" href="ohneSachbegriff.xml">
			<z:application>
				<!-- related PK records etc. may be missing here-->
				<z:modules>
					<z:module name="Object" totalSize="{count($ohneSachbegriff)}">
						<xsl:copy-of select="$ohneSachbegriff"/>
					</z:module>
				</z:modules>
			</z:application>
		</xsl:result-document>
	</xsl:template>
</xsl:stylesheet>
